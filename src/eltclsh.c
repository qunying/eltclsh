/*	$LAAS$ */

/* 
 * Copyright (c) 2001 LAAS/CNRS                       --  Wed Oct 10 2001
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

#ifdef VXWORKS
#include <vxWorks.h>

#include <ioLib.h>
#include <taskLib.h>
#include <taskVarLib.h>
#endif /* VXWORKS */

#include "eltclsh.h"


/*
 * Startup --------------------------------------------------------------
 *
 * Spawn the task (VxWorks) or simply start the application (Unix)
 */

#ifdef VXWORKS
static STATUS rtclshReal(char *);

STATUS
eltclsh(char *script)
{
   return taskSpawn("trtclsh",
		    RTCLSH_PRIORITY, 8, 30000, rtclshReal, script);
}

static STATUS
rtclshReal(char *script)
{
   char *argv[2] = { "tcl" };
   argv[1] = script;

   if (taskVarAdd(taskIdSelf(),(int *)&InterpInfo) == ERROR)
      fatal_error(-1, "error adding VxWorks task variable\n");
   if ((InterpInfo = malloc(sizeof(RTcl_InterpInfo))) == NULL)
      fatal_error(-1, "Unable to alloc memory for tclServ global structure");
   
   Tcl_Main(1, argv, rtclshAppInit);
   return OK;
}
#else /* UNIX */

#if TCL_MAJOR_VERSION >= 8 && TCL_MINOR_VERSION >= 4
int 
main(int argc, const char *argv[])
#else
int 
main(int argc, char *argv[])
#endif /* TCL_VERSION */
{
   elTclshLoop(argc, argv, elTclAppInit);
   return 0;
}
#endif /* VXWORKS */
