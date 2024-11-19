**free

// declare a data structure that is used to store the SUCCESS/FAIL status and
// the ERRORMSG value. This template is referenced through this program.
dcl-ds rtnCode_Template qualified template;
  success ind inz(*off);
  errorMsg varchar(500) inz('');
end-ds;

// Global Data Structure to webservice return codes
dcl-ds ds_RtnCode likeds(rtnCode_Template) inz(*likeds);

