/*	$LAAS$ */

/* 
 * Copyright (c) 2001 LAAS/CNRS                       --  Tue Oct 16 2001
 * All rights reserved.                                    Anthony Mallet
 *
 * Redistribution and use  in source  and binary  forms,  with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *   1. Redistributions of  source  code must retain the  above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice,  this list of  conditions and the following disclaimer in
 *      the  documentation  and/or  other   materials provided  with  the
 *      distribution.
 *
 * THIS  SOFTWARE IS PROVIDED BY  THE  COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND  ANY  EXPRESS OR IMPLIED  WARRANTIES,  INCLUDING,  BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES  OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR  PURPOSE ARE DISCLAIMED. IN  NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR      CONTRIBUTORS  BE LIABLE FOR   ANY    DIRECT, INDIRECT,
 * INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF  SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE   OF THIS SOFTWARE, EVEN   IF ADVISED OF   THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
#include "config.h"
__RCSID("$LAAS$");

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <libgen.h>

#include "eltclsh.h"

static char copyright[] = " - Copyright (C) 2001-2003 LAAS-CNRS";


/*
 * elTclshLoop ----------------------------------------------------------
 *
 * Main loop: it reads commands and execute them
 */

void
elTclshLoop(int argc, char **argv, ElTclAppInitProc appInitProc)
{
   ElTclInterpInfo *iinfo;
   HistEvent ev;

   Tcl_Obj *resultPtr, *command;
   char buffer[1000], *args, *fileName, *bytes;
   int code, tty, length;
   int exitCode = 0;
   Tcl_Channel inChannel, outChannel, errChannel;

   /* create main data structure */
   iinfo = malloc(sizeof(*iinfo));
   if (iinfo == NULL) {
      fputs("cannot alloc %d bytes\n", stderr);
      return;
   }

   /* initialize interpreter */
   iinfo->interp = Tcl_CreateInterp();
   if (iinfo->interp == NULL) {
      fputs("cannot create tcl interpreter\n", stderr);
      free(iinfo);
      return;
   }

   /*
    * Make command-line arguments available in the Tcl variables "argc"
    * and "argv".  If the first argument doesn't start with a "-" then
    * strip it off and use it as the name of a script file to process.
    */

   fileName = NULL;
   if ((argc > 1) && (argv[1][0] != '-')) {
      fileName = argv[1];
      argc--; argv++;
   }
   args = Tcl_Merge(argc-1, argv+1);
   Tcl_SetVar(iinfo->interp, "argv", args, TCL_GLOBAL_ONLY);
   Tcl_Free(args);
   sprintf(buffer, "%d", argc-1);
   Tcl_SetVar(iinfo->interp, "argc", buffer, TCL_GLOBAL_ONLY);
   args = (fileName != NULL) ? fileName : argv[0];
   Tcl_SetVar(iinfo->interp, "argv0", args, TCL_GLOBAL_ONLY);
   iinfo->argv0 = basename(args);


   /* Set the "tcl_interactive" variable. */
   tty = isatty(0);
   Tcl_SetVar(iinfo->interp, "tcl_interactive",
	      ((fileName == NULL) && tty) ? "1" : "0", TCL_GLOBAL_ONLY);
    
   /* Invoke application-specific initialization. */
   if ((*appInitProc)(iinfo) != TCL_OK) {
      errChannel = Tcl_GetStdChannel(TCL_STDERR);
      if (errChannel) {
	 char *msg;

	 msg = Tcl_GetVar(iinfo->interp, "errorInfo", TCL_GLOBAL_ONLY);
	 if (msg != NULL) {
	    Tcl_Write(errChannel, msg, strlen(msg));
	    Tcl_Write(errChannel, "\n", 1);
	 }
	 resultPtr = Tcl_GetObjResult(iinfo->interp);
	 bytes = Tcl_GetStringFromObj(resultPtr, &length);
	 Tcl_Write(errChannel, bytes, length);
	 Tcl_Write(errChannel, "\n", 1);
      }

      exitCode = 2;
      goto done;
   }

   (void)Tcl_SourceRCFile(iinfo->interp);
   Tcl_Flush(Tcl_GetStdChannel(TCL_STDERR));

   /* If a script file was specified then just source that file and
    * quit. */
   if (fileName != NULL) {
      code = Tcl_EvalFile(iinfo->interp, fileName);
      if (code != TCL_OK) {
	 errChannel = Tcl_GetStdChannel(TCL_STDERR);
	 if (errChannel) {
	    /* The following statement guarantees that the errorInfo
	     * variable is set properly. */
	    Tcl_AddErrorInfo(iinfo->interp, "");
	    Tcl_Write(errChannel,
		      Tcl_GetVar(iinfo->interp, "errorInfo", TCL_GLOBAL_ONLY),
		      -1);
	    Tcl_Write(errChannel, "\n", 1);
	 }

	 exitCode = 1;
      }
     
      goto done;
   }

   /* Print the copyright message in interactive mode */
   if (tty) {
      char version[32];

      snprintf(version, sizeof(version),
	       " %d.%d", ELTCLSH_MAJOR, ELTCLSH_MINOR);
      length = (iinfo->windowSize -
		(int)(strlen(version)+
		      strlen(copyright)+strlen(iinfo->argv0)))*3/4;
      if (length >= 0) {
	 fputc('\n', stdout);
	 for(;length;length--) fputc(' ', stdout);
	 fputs(iinfo->argv0, stdout);
	 fputs(version, stdout);
	 fputs(copyright, stdout);
	 fputs("\n\n", stdout);
      }
   }

   /*
    * Process commands from stdin until there's an end-of-file. Note
    * that we need to fetch the standard channels again after every
    * eval, since they may have been changed.
    */

   iinfo->command = Tcl_NewObj();
   Tcl_IncrRefCount(iinfo->command);
    
   inChannel = Tcl_GetStdChannel(TCL_STDIN);
   outChannel = Tcl_GetStdChannel(TCL_STDOUT);
   iinfo->gotPartial = 0;

   for(;/*eternity*/;)  {

      if (tty) {
	 const char *line;

	 line = el_gets(iinfo->el, &length);
	 if (line == NULL) goto done;

	 command = Tcl_NewStringObj(line, length);
	 Tcl_AppendObjToObj(iinfo->command, command);

      } else {
	 /* using libedit but not a tty - must use gets */
	 if (!inChannel) goto done;

	 length = Tcl_GetsObj(inChannel, iinfo->command);
	 if (length < 0) goto done;
	 if ((length == 0) && 
	     Tcl_Eof(inChannel) && (!iinfo->gotPartial)) goto done;

	 /* Add the newline back to the string */
	 Tcl_AppendToObj(iinfo->command, "\n", 1);
      }
       
      if (!Tcl_CommandComplete(
	     Tcl_GetStringFromObj(iinfo->command, &length))) {
	 iinfo->gotPartial = 1; continue;
      }

      if (tty && length > 1) {
	 /*  add the command line to history */
	 history(iinfo->history, &ev, H_ENTER,
		 Tcl_GetStringFromObj(iinfo->command, NULL));
      }

      /* tricky: if the command calls el::get[sc], the completion engine
       * will think that iinfo->command is the beginning of an incomplete
       * command. Thus we must reset it before the Tcl_Eval call... */
      command = iinfo->command;

      iinfo->command = Tcl_NewObj();
      Tcl_IncrRefCount(iinfo->command);

      iinfo->gotPartial = 0;
      code = Tcl_EvalObj(iinfo->interp, command);

      Tcl_DecrRefCount(command);

      inChannel = Tcl_GetStdChannel(TCL_STDIN);
      outChannel = Tcl_GetStdChannel(TCL_STDOUT);
      errChannel = Tcl_GetStdChannel(TCL_STDERR);
      if (code != TCL_OK) {
	 if (errChannel) {
	    resultPtr = Tcl_GetObjResult(iinfo->interp);
	    bytes = Tcl_GetStringFromObj(resultPtr, &length);
	    Tcl_Write(errChannel, bytes, length);
	    Tcl_Write(errChannel, "\n", 1);
	 }
      } else if (tty) {
	 resultPtr = Tcl_GetObjResult(iinfo->interp);
	 bytes = Tcl_GetStringFromObj(resultPtr, &length);

	 if ((length > 0) && outChannel) {
	    Tcl_Write(outChannel, bytes, length);
	    Tcl_Write(outChannel, "\n", 1);
	 }
      }
   }

   /*
    * Rather than calling exit, invoke the "exit" command so that
    * users can replace "exit" with some other command to do additional
    * cleanup on exit.  The Tcl_Eval call should never return.
    */

 done:
   if (iinfo->command != NULL) Tcl_DecrRefCount(iinfo->command);
   sprintf(buffer, "exit %d", exitCode);
   Tcl_Eval(iinfo->interp, buffer);
}


/*
 * elTclExit ------------------------------------------------------------
 *
 * Destroy global info structure
 */

int
elTclExit(ClientData data,
	  Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
   ElTclInterpInfo *iinfo = data;
   int value;

   if ((objc != 1) && (objc != 2)) {
      Tcl_WrongNumArgs(interp, 1, objv, "?returnCode?");
      return TCL_ERROR;
   }
    
   if (objc == 1) {
      value = 0;
   } else if (Tcl_GetIntFromObj(interp, objv[1], &value) != TCL_OK) {
      return TCL_ERROR;
   }

   el_end(iinfo->el);
   history_end(iinfo->history);
   history_end(iinfo->askaHistory);

   elTclHandlersExit(iinfo);
   Tcl_DecrRefCount(iinfo->prompt1Name);
   Tcl_DecrRefCount(iinfo->prompt2Name);
   Tcl_DecrRefCount(iinfo->matchesName);
   free(iinfo);

   fputs("\n", stdout);
   Tcl_Exit(value);
   return TCL_OK;
}
