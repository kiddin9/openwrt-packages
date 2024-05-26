
$Id$


This file contains some small notes on developing the WiFiDog application.

The application's home page is:
	http://www.ilesansfil.org/wiki/WiFiDog

The application's sourceforge page is:
	http://sourceforge.net/projects/wifidog/

As a developer, you must subscribe to sourceforge as a "developer" under WiFiDog, as well as subscribe to the WiFiDog mailing list located at:
	http://listes.ilesansfil.org/cgi-bin/mailman/listinfo/wifidog


SOURCE CODE:
	- Please do not contribute unless you agree with the GPL license and are contributing your portion under that license.  See the included LICENSE.txt
	- Please respect the intellectual property of others.  You are not allowed to taint WiFiDog by including source code from projects that do not allow so.
	- Keep in mind that this application will run on extremely simple embedded devices.  The binary size needs to be small, the dependencies absolutely minimal, and the memory footprint negligible.
	- Always place the subversion "Id" macro at the top of every file
	- Since this is a collaborative project, please aim for clearness instead of cleverness when faced with a choice.
	- If you must use some cleverness, please add appropriate clear comments.
	- Please re-indent your code before committing to subversion - see the "Formatting Your Source Code" section in the GNU Coding Standards at http://www.gnu.org/prep/standards_toc.html - the entire document makes a good reading if you haven't read it before.  Also see the "indent" program.
	- Before writing any brand-new large chunks of code, make sure it's logic has been discussed with the other team of developers or included in the design stage.


MEMORY ALLOCATION IN SOURCE CODE:
	- Safe versions of C functions that allocate memory (safe_malloc, safe_asprintf, etc..) have been created in safe.c . You must use them instead of the original functions.
	- If you need to use a memory-allocating C function that does not have a safe version in safe.c, create the safe wrapper first (following the template of the others) and use that instead of calling the original.


DOCUMENTATION:
	- Please use DoxyGen-style comments (see http://www.doxygen.org/ for details) for source code documentation.
	- Please use DocBook-SGML documentation for user documentation.  This will make it easy to export documentation in multiple formats.  Otherwise submit your documentation in plaintext format to someone who will change it to DocBook.
	- Please thoroughly-comment non-clear sections in your code.

