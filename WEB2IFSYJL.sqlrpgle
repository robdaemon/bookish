**free
/title Webserver listening for incoming JSON and storing in IFS - Proof of Concept

// ----------------------------------------------------------​
//
// Service - WEB2IFSYJL
//
// Function - This interface will be used to receive incoming
//     connection containing JSON payload. The webservice body
//     of JSON will be written to IFS(/HOME/NICKLITTEN)
//     for processing by program JSNIFSYAJL in the next step.
//
// ----------------------------------------------------------
//
// COMPILE NOTES:
// I am using a copy of the YAJL utilities that have been
// installed in a library called PROJEX3RD: A library
// that I use that contains all my third party applications.
// Perhaps you installed it in a library called YAJL so
// you would need to reference that library instead
//
// When you test the webservice code include a parameter value
// of debug=Y to print useful debugging information
//
// To compile:
// (1) Create a library called WEBSERVICE (this is referenced in 
//     the HTTP SERVER configuration. This is the library that
//     all of these YAJL web services reside in)
// (2) compile the SQLRPGLE PGM into LIB(WEBSERVICE)
//
// Obviously change the source location to match yours:
//
// CRTSQLRPGI OBJ(WEBSERVICE/WEB2IFSYJL)                     
//            SRCSTMF('/home/nicklitten/source/WEB2IFSYJL.sqlrpgle')                                  
//            COMMIT(*NONE)                                  
//            OBJTYPE(*PGM)                               
//            DBGVIEW(*SOURCE)                               
//            CVTCCSID(*JOB)                                           
//
// ----------------------------------------------------------
// Modification History:
// 2021-06-31 V1.0 Created by Nick Litten
// 2024-09-23 V1.1 Add debugging & modernize
// 2024-09-28 V1.2 Add GET code for example data return JSON
// 2024-09-29 V1.3 Extra logic for GET/PUT/POST/DELETE
// ----------------------------------------------------------

ctl-opt
  Main(mainline)
  pgminfo(*PCML:*MODULE:*DCLCASE)
  option(*srcstmt:*nodebugio:*noshowcpy)
  decedit('0.')
  bnddir('YAJL':'QC2LE')
  /if Defined(*CRTSQLRPGI)
   dftactgrp(*no) actgrp('NICKLITTEN') 
  /endIf
  copyright('WEB2IFSYJL: Version 1.3 September 2024');

// declare a good old PRINTER for easy debugging
dcl-f QPRINT printer(132) usropn;
dcl-ds line len(132) inz qualified;
    printString char(132);
end-ds;

dcl-s method varchar(10);
dcl-s request char(500);
dcl-s env pointer;
dcl-s errmsg varchar(500) inz('Oops');
dcl-s webservice varchar(100);
dcl-s debug char(1);

// include the YAJL magic (this srcmbr lives in YAJL/QRPGLESRC by default)
/include YAJL_H

// declare a data structure that is used to store the SUCCESS/FAIL status and
// the ERRORMSG value. This template is referenced through this program.
dcl-ds rtnCode_Template qualified template;
    success ind inz(*off);
    errorMsg varchar(500) inz('');
end-ds;

// This is the variable we will populate with the IFS location that the 
// incoming JSON payload will be stored at
dcl-s payloadIFS varchar(500);

// Global Data Structure to webservice return codes
dcl-ds ds_RtnCode likeds(rtnCode_Template) inz(*likeds);

// The Program Status Data Structure to see the program name
dcl-ds psds PSDS qualified;
    program char(10) pos(1);
    jobUserNumber char(26) pos(244);
    job char(10) pos(244);
    jobUser char(10) pos(254);
    jobNumber char(6) pos(264);
end-ds;







//--  WEB2IFSYJL - Process the incoming webservice JSON payload
//--  mainline() : If a POST was requested (write) then read JSON payload and save to the IFS location
//--  returns *ON if successful, *OFF otherwise
dcl-proc mainline;
    dcl-pi mainline end-pi;

    monitor;

        // Set SQL option, mainly to force cursor to close at endmodule
        exec sql
            set option naming = *sys,
            commit = *none,
            usrprf = *user,
            dynusrprf = *user,
            datfmt = *iso,
            closqlcsr = *endmod;

        // Initiliase program variables
        init();

        // Now process the different incoming methods
        select;
            when method = 'GET';
                methodGET(ds_RtnCode);
            when method = 'PUT';
                methodPUT(ds_RtnCode);
            when method = 'POST';
                methodPOST(ds_RtnCode);
            when method = 'DELETE';
                methodDELETE(ds_RtnCode);
            other;
                ds_RtnCode.errorMsg = webservice+' method(' + method + ')' + ' is not supported';                     
        endsl;

        if debug <> '';            
            line.printstring='Final:'+ds_RtnCode.errorMsg;
            write QPRINT line;
            close qprint;
        endif;

        // Send the JSON response document
        sendResponse(ds_RtnCode);

        return;

    on-error ;
        dump(a);
        dsply ('*** Webservice(' + %trim(psds.program) + ') has failed!');
    endmon ;

end-proc;






//--  -------------------------------------------------------------------
//--  methodGET() : If a GET was requested (write) then read JSON payload and save to the IFS location
//--  Parameter is the table containing a SUCCESS flag and any Error Description if FAIL
//--  returns *ON if successful, *OFF otherwise
//--  -------------------------------------------------------------------
dcl-proc methodGET;
    dcl-pi *n ind;
        ds_methodGET likeds(rtnCode_Template);
    end-pi;

    ds_methodGET.success = *off;
    ds_methodGET.errorMsg = webservice+' method(GET) is Invalid';

    return ds_methodGET.success;

end-proc;







//--  -------------------------------------------------------------------
//--  methodPUT() : If a PUT was requested (write) then read JSON payload and save to the IFS location
//--  Parameter is the table containing a SUCCESS flag and any Error Description if FAIL
//--  returns *ON if successful, *OFF otherwise
//--  -------------------------------------------------------------------
dcl-proc methodPUT;
    dcl-pi *n ind;
        ds_methodPUT likeds(rtnCode_Template);
    end-pi;

    ds_methodPUT.success = *off;
    ds_methodPUT.errorMsg = webservice+' method(PUT) is Invalid';
                
    return ds_methodPUT.success;

end-proc;







//--  -------------------------------------------------------------------
//--  methodPOST() : If a POST was requested (write) then read JSON payload and save to the IFS location
//--  Parameter is the table containing a SUCCESS flag and any Error Description if FAIL
//--  returns *ON if successful, *OFF otherwise
//--  -------------------------------------------------------------------
dcl-proc methodPOST;
    dcl-pi *n ind;
        ds_methodPOST likeds(rtnCode_Template);
    end-pi;

    dcl-s docNode like(yajl_val);
    dcl-s node like(yajl_val);
    dcl-s dataNode like(yajl_val);
    dcl-s data like(yajl_val);
    dcl-s addrNode like(yajl_val);
    dcl-s errmsg varchar(500);
    dcl-s payload_ifs varchar(500);
    
    payload_ifs = '/home/nicklitten/WEB2IFSRPG-new-' +
                  %char(%timestamp:*iso0) + '.json';

    // get the JSON document sent from the consumer and
    // save to the IFS location
    docNode = yajl_stdin_load_tree (*on: errmsg : payload_ifs);

    if (docNode = *NULL) or (errmsg <> ' ');
        ds_methodPOST.success = *off;
        ds_methodPOST.errorMsg = '* Webservice(' + %trim(psds.program) +
                                 ') failed with error: ' + errmsg;
    else;
        ds_methodPOST.success = *on;
        ds_methodPOST.errorMsg = 'Webservice(' + %trim(psds.program) +
                                 ') Success. Json successfully stored at:' +
                                 payload_ifs;
    endif;

    yajl_tree_free(docNode);

    return ds_methodPOST.success;

end-proc;







//--  -------------------------------------------------------------------
//--  methodDELETE() : If a DELETE was requested (write) then read JSON payload and save to the IFS location
//--  Parameter is the table containing a SUCCESS flag and any Error Description if FAIL
//--  returns *ON if successful, *OFF otherwise
//--  -------------------------------------------------------------------
dcl-proc methodDELETE;
    dcl-pi *n ind;
        ds_methodDELETE likeds(rtnCode_Template);
    end-pi;

    ds_methodDELETE.success = *off;
    ds_methodDELETE.errorMsg = webservice+' method(DELETE) is Invalid';
                
    return ds_methodDELETE.success;

end-proc;







//--  -------------------------------------------------------------------
//--  init() : program Initilisation
//--  returns *ON if successful, *OFF otherwise.
//--  -------------------------------------------------------------------
dcl-proc init;
    dcl-pi *n ind end-pi;

    // This procedure will return the webservice METHOD
    dcl-pr getenv pointer extproc(*dclcase);
        var pointer value options(*string);
    end-pr;

    // This is optional - because you can set the *LIBL in the webservice
    // setup within the Integrated Webserver Setup.
    // I prefer to  use a LIBL Control Application here but for this
    // example I *could* do a simple CHGLIBL.
    exec sql
          call qsys2.qcmdexc('CHGLIBL (QTEMP NICKLITTEN PROJEX3RD QGPL)');

    clear ds_RtnCode;

    // if the DEBUG=Y parm has come in from the webserver start the debug
    // print and store a more detailed version of variable 'webserver'
    if debug <> '';            
        open qprint;
        webservice='WEB2IFSYJL('+%trim(psds.jobNumber)+
                   '/'+%trim(psds.jobuser)+'/'+%trim(psds.job)+'): ';
        line.printstring='Debug for:'+webservice;
        write QPRINT line;
    else;
        webservice='WEB2IFSYJL: ';
    endif;

    // set location and unique file name for the payload JSON to
    // be saved in.
    payloadIFS = '/home/nicklitten/WEB2IFSYJL-new-' +
                  %char(%timestamp:*iso0) + '.json';

    // Retrieve the HTTP method - Default to GET if not provided
    env = getenv('REQUEST_METHOD');
    if env <> *null;
        method = %upper(%str(env));
    else;
        method = 'GET';
    endif;

    if debug <> '';
        line.printstring='AFTER method:'+method;
        write QPRINT line;
    endif;

    return *on;

end-proc;








//--  -------------------------------------------------------------------
//--  sendResponse() : Send the JSON response document
//--  returns *ON if successful, *OFF otherwise.
//--  -------------------------------------------------------------------
dcl-proc sendResponse;
    dcl-pi *n ind;
        ds_sendResponse likeds(rtnCode_Template) const;
    end-pi;

    yajl_genOpen(*on);
    yajl_beginObj();

    yajl_beginArray(%trim(psds.program));
    yajl_beginObj(); 
    yajl_addBool('success': ds_sendResponse.success);
    yajl_addChar('errorMsg': ds_sendResponse.errorMsg);
    yajl_endObj(); 
    yajl_endArray(); 

    yajl_endObj();

    errmsg = ds_sendResponse.errorMsg;
    if ds_sendResponse.success;
        yajl_writeStdout(200: errmsg);
    else;
        yajl_writeStdout(500: errmsg);
    endif;

    yajl_genClose();

    return ds_sendResponse.success;

end-proc;