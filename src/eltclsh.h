/*
 * Copyright (c) 2001, 2010-2011, 2017, 2025 LAAS/CNRS -- Wed Oct 10 2001
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
 *
 *                                      Anthony Mallet on Wed Oct 10 2001
 */
#ifndef H_ELTCLSH
#define H_ELTCLSH

#include <tcl.h>
#include <histedit.h>

#if TCL_MAJOR_VERSION < 9
/* backward compatibility: tcl-8 has no Tcl_Size and uses int in API */
typedef int Tcl_Size;
#endif

#include "parse.h"

/* A structure that groups together the various parameters that control
 * the behavior of eltclsh/elwish */
typedef struct ElTclInterpInfo {
   char *argv0;			/* the basename of the program */
   Tcl_Interp *interp;		/* the main Tcl interpreter */

#define ELTCL_RDSZ 16
   char preRead[ELTCL_RDSZ];	/* characters read on stdin and not yet
				 * processed */
   int preReadSz;		/* number of valid characters above */

   EditLine *el;		/* editline structure */
   History *history;		/* main command history */
   Tcl_Obj *prompt1Name;	/* name of the prompt procedures */
   Tcl_Obj *prompt2Name;
   Tcl_Obj *promptString;	/* prompt to display if not NULL */

   History *askaHistory;	/* history for el::get[sc] commands */

   int editmode;		/* true if editline features wanted */
   int windowSize;		/* current terminal size */

   int completionQueryItems;	/* maximum number of items the completion
				 * engine can display before asking user
				 * it he really wants to see all these
				 * items */
   Tcl_Obj *matchesName;	/* name of the procedure that generates
				 * completion matches */

   Tcl_Obj *command;		/* current interactive command */
   int gotPartial;		/* true if current command is incomplete */
   int isTk;			/* true if this is a Tk interpreter */
   int maxCols;			/* limit columns in completion output */
   int histSize;		/* history length (800) */
   const char *histFile;	/* history filename (~/.eltclhistory) */
} ElTclInterpInfo;

typedef int (*ElTclAppInitProc)(Tcl_Interp *);


/*
 * Prototypes -----------------------------------------------------------
 */

void		elTclshLoop(int argc, const char * const *argv,
			ElTclAppInitProc appInitProc);
int		elTclInteractive(ClientData data, Tcl_Interp *interp, int objc,
			Tcl_Obj *const objv[]);
int		elTclExit(ClientData data, Tcl_Interp *interp, int objc,
			Tcl_Obj *const objv[]);

int		Eltclsh_Init(Tcl_Interp *interp);

unsigned char	elTclCompletion(EditLine *el, int ch);
int		elTclBreakCommandLine(ClientData data,
			Tcl_Interp *interp, int objc,
			Tcl_Obj *const objv[]);

int		elTclParseCommand(char *string, int numBytes, int nested,
			ElTclParse *parsePtr);
void		elTclFreeParse(ElTclParse *parsePtr);

int		elTclHandlersInit(ElTclInterpInfo *iinfo);
void		elTclHandlersExit(ElTclInterpInfo *iinfo);

int		elTclGets(ClientData data, Tcl_Interp *interp, int objc,
			Tcl_Obj *const objv[]);
int		elTclGetc(ClientData data, Tcl_Interp *interp, int objc,
			Tcl_Obj *const objv[]);
int		elTclHistory(ClientData data, Tcl_Interp *interp,
			int objc, Tcl_Obj *const objv[]);
int		elTclEventLoop(EditLine *el, wchar_t *c);
void		elTclRead(ClientData data, int mask);
int		elTclGetWindowSize(int fd, int *lins, int *cols);


int	rtclshWrappedPutsCmd(ClientData, Tcl_Interp *, int,
				Tcl_Obj *const[]); 

#endif /* H_ELTCLSH */
