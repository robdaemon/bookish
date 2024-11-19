**free
ctl-opt nomain;

/COPY INCLUDE,DATAMDL

/COPY INCLUDE,HTTPRTN

/COPY INCLUDE,PSDS

dcl-proc ADDBOOK;
  dcl-pi ADDBOOK end-pi;

  monitor;

  endmon;
end-proc;

dcl-proc methodGET;
  dcl-pi *n ind;
    ds_methodGET likeds(rtnCode_Template);
  end-pi;

  ds_methodGET.success=*off;
  ds_methodGET.errorMsg='* Fail - method(GET) is Invalid';

  return ds_methodGET.success;

end-proc;

