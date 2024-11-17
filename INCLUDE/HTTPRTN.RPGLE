000100241116**free
000101241116
000102241116// declare a data structure that is used to store the SUCCESS/FAIL status and
000103241116// the ERRORMSG value. This template is referenced through this program.
000104241116dcl-ds rtnCode_Template qualified template;
000105241116  success ind inz(*off);
000106241116  errorMsg varchar(500) inz('');
000107241116end-ds;
000108241116
000109241116// Global Data Structure to webservice return codes
000110241116dcl-ds ds_RtnCode likeds(rtnCode_Template) inz(*likeds);
000111241116
000112241116dcl-ds psds PSDS qualified;
000113241116  program char(10) pos(1);
000114241116  procedureName *PROC;
000115241116  statusCode *STATUS;
000116241116  prvStatus zoned(5) pos(16);
000117241116  srcListLineNum char(8) pos(21);
000118241116  routineName *ROUTINE;
000119241116  nbrPassedParms *PARMS;
000120241116  exceptionType char(3) pos(40);
000121241116  exceptionNumber char(4) pos(43);
000122241116  pgmLib char(10) pos(81);
000123241116  ExceptionData char(80) pos(91);
000124241116  messageText char(80) pos(91);
000125241116  ExceptionId char(4) pos(171);
000126241116  date char(8) pos(191);
000127241116  year zoned(2) pos(199);
000128241116  lastFileUsed char(8) pos(201);
000129241116  fileErrorInfo char(35) pos(209);
000130241116  rpgFileRoutine char(6) pos(214);
000131241116  rpgStatement char(6) pos(214);
000132241116  fileRecordFormat char(8) pos(236);
000133241116  jobUserNumber char(26) pos(244);
000134241116  job char(10) pos(244);
000135241116  jobName char(10) pos(244);
000136241116  User char(10) pos(254);
000137241116  jobUser char(10) pos(254);
000138241116  number zoned(6) pos(264);
000139241116  jobnumber zoned(6) pos(264);
000140241116  jobnumberalpha char(6) pos(264);
000141241116  jobDate zoned(6) pos(270);
000142241116  runDate zoned(6) pos(276);
000143241116  runTime zoned(6) pos(282);
000144241116  runtimeHour char(2) pos(282);
000145241116  runtimeMinute char(2) pos(284);
000146241116  runtimeSecond char(2) pos(286);
000147241116  createDate char(6) pos(288);
000148241116  createTime char(6) pos(294);
000149241116  compilerLevel char(4) pos(300);
000150241116  srcFile char(10) pos(304);
000151241116  srcLib char(10) pos(314);
000152241116  srcMbr char(10) pos(324);
000153241116  currentPgmProc char(10) pos(334);
000154241116    currentModule char(10) pos(344);
000155241116  currentUser char(10) pos(358);
000156241116  systemName char(8) pos(396);
000157241116end-ds;
000158241116
