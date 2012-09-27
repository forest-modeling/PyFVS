//  $Id$

// c program to build DBSTYPEDEFS.F77 for the system on which it is run.

#ifdef WINDOWS
#include <windows.h>
#endif

#include <stdio.h>
#include <sql.h>
#include <sqlext.h>

int main(void)
{

  SQLCHAR       SQLCHAR_KIND;     
  SQLSMALLINT   SQLSMALLINT_KIND;  
  SQLUSMALLINT  SQLUSMALLINT_KIND; 
  SQLINTEGER    SQLINTEGER_KIND;   
  SQLUINTEGER   SQLUINTEGER_KIND; 
  SQLREAL       SQLREAL_KIND;      
  SQLDOUBLE     SQLDOUBLE_KIND;    
  SQLLEN        SQLLEN_KIND;       
  SQLFLOAT      SQLFLOAT_KIND;   
  SQLRETURN     SQLRETURN_KIND;   
  SQLPOINTER    SQLPOINTER_KIND;
  SQLHANDLE     SQLHANDLE_KIND;    
  SQLHENV       SQLHENV_KIND;      
  SQLHDBC       SQLHDBC_KIND;      
  SQLHSTMT      SQLHSTMT_KIND;     
  SQLHDESC      SQLHDESC_KIND;     
  SQLHWND       SQLHWND_KIND;      
  SQLULEN       SQLULEN_KIND;      
  
  FILE *out;
  out = fopen("DBSTYPEDEFS.F77","w");
  fprintf(out,"CODE SEGMENT DBSTYPEDEFS\n");
  fprintf(out,"C\n");
  fprintf(out,"C  generated using mkbsTypeDefs.c\n");
  fprintf(out,"C\n\n");
 
  fprintf(out,"      integer,parameter:: SQLCHAR_KIND=      %i\n",sizeof(SQLCHAR_KIND     ));             
  fprintf(out,"      integer,parameter:: SQLSMALLINT_KIND=  %i\n",sizeof(SQLSMALLINT_KIND));             
  fprintf(out,"      integer,parameter:: SQLUSMALLINT_KIND= %i\n",sizeof(SQLUSMALLINT_KIND));
  fprintf(out,"      integer,parameter:: SQLINTEGER_KIND=   %i\n",sizeof(SQLINTEGER_KIND  ));             
  fprintf(out,"      integer,parameter:: SQLUINTEGER_KIND=  %i\n",sizeof(SQLUINTEGER_KIND ));
  fprintf(out,"      integer,parameter:: SQLREAL_KIND=      %i\n",sizeof(SQLREAL_KIND     ));             
  fprintf(out,"      integer,parameter:: SQLDOUBLE_KIND=    %i\n",sizeof(SQLDOUBLE_KIND   ));            
  fprintf(out,"      integer,parameter:: SQLLEN_KIND=       %i\n",sizeof(SQLLEN_KIND      ));
  fprintf(out,"      integer,parameter:: SQLFLOAT_KIND=     %i\n",sizeof(SQLFLOAT_KIND    ));
  fprintf(out,"      integer,parameter:: SQLRETURN_KIND=    %i\n",sizeof(SQLRETURN_KIND   ));
  fprintf(out,"\n");
  fprintf(out,"      integer,parameter:: SQLPOINTER_KIND=   %i\n",sizeof(SQLPOINTER_KIND  ));
  fprintf(out,"      integer,parameter:: SQLHANDLE_KIND=    %i\n",sizeof(SQLHANDLE_KIND   ));
  fprintf(out,"      integer,parameter:: SQLHENV_KIND=      %i\n",sizeof(SQLHENV_KIND     ));
  fprintf(out,"      integer,parameter:: SQLHDBC_KIND=      %i\n",sizeof(SQLHDBC_KIND     ));
  fprintf(out,"      integer,parameter:: SQLHSTMT_KIND=     %i\n",sizeof(SQLHSTMT_KIND    ));
  fprintf(out,"      integer,parameter:: SQLHDESC_KIND=     %i\n",sizeof(SQLHDESC_KIND    ));
  fprintf(out,"      integer,parameter:: SQLHWND_KIND=      %i\n",sizeof(SQLHWND_KIND     ));
  fprintf(out,"      integer,parameter:: SQLULEN_KIND=      %i\n",sizeof(SQLULEN_KIND     ));
  fprintf(out,"\n");
  fprintf(out,"      integer,parameter:: SQL_OV_ODBC3_KIND= %i\n",sizeof(SQL_OV_ODBC3));
  fprintf(out,"\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLAllocHandle\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLBindCol\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLBindParameter\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLCloseCursor\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLColAttribute\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLGetData\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLDescribeCol\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLDisconnect\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLDriverConnect\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLDrivers\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLEndTran\n");   
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLExecDirect\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLExecute\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLFetch\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLFetchScroll\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLFreeHandle\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLFreeStmt\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLGetDiagRec\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLGetInfo\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLNumResultCols\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLPrepare\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLSetConnectAttr\n");
  fprintf(out,"      integer(SQLRETURN_KIND) :: fvsSQLSetEnvAttr\n");
  fprintf(out,"\n");
  fprintf(out,"      integer(SQL_OV_ODBC3_KIND), parameter::\n");
  fprintf(out,"     -                         SQL_OV_ODBC3 = %i\n", SQL_OV_ODBC3);
  fprintf(out,"      integer(SQLPOINTER_KIND),   parameter::\n");
  fprintf(out,"     -                         SQL_NULL_PTR = 0\n");
  fprintf(out,"      integer(SQLINTEGER_KIND),   parameter::\n");
  fprintf(out,"     -                        SQL_NULL_DATA = %i\n", SQL_NULL_DATA );
  fprintf(out,"      integer(SQLINTEGER_KIND),   parameter::\n");
  fprintf(out,"     -                     SQL_DATA_AT_EXEC = %i\n", SQL_DATA_AT_EXEC);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                          SQL_SUCCESS = %i\n", SQL_SUCCESS);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                SQL_SUCCESS_WITH_INFO = %i\n", SQL_SUCCESS_WITH_INFO);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                          SQL_NO_DATA = %i\n", SQL_NO_DATA);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                            SQL_ERROR = %i\n", SQL_ERROR);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                   SQL_INVALID_HANDLE = %i\n", SQL_INVALID_HANDLE);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                  SQL_STILL_EXECUTING = %i\n", SQL_STILL_EXECUTING);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                        SQL_NEED_DATA = %i\n", SQL_NEED_DATA);
  fprintf(out,"      integer(SQLRETURN_KIND),    parameter::\n");
  fprintf(out,"     -                   SQL_NO_IMPLEMENTED = %i\n", SQL_NEED_DATA);
  fprintf(out,"      integer(SQLINTEGER_KIND),   parameter::\n");
  fprintf(out,"     -                              SQL_NTS = %i\n", SQL_NTS);
  fprintf(out,"      integer(SQLINTEGER_KIND),   parameter::\n");
  fprintf(out,"     -                             SQL_NTSL = %i\n", SQL_NTSL);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -               SQL_MAX_MESSAGE_LENGTH = %i\n", SQL_MAX_MESSAGE_LENGTH);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                       SQL_HANDLE_ENV = %i\n", SQL_HANDLE_ENV);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                       SQL_HANDLE_DBC = %i\n", SQL_HANDLE_DBC);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                      SQL_HANDLE_STMT = %i\n", SQL_HANDLE_STMT);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                      SQL_HANDLE_DESC = %i\n", SQL_HANDLE_DESC);
  fprintf(out,"      integer(SQLINTEGER_KIND),   parameter::\n");
  fprintf(out,"     -                SQL_ATTR_ODBC_VERSION = %i\n", SQL_ATTR_ODBC_VERSION);
  fprintf(out,"      integer(SQLUSMALLINT_KIND), parameter::\n");
  fprintf(out,"     -                            SQL_CLOSE = %i\n", SQL_CLOSE);
  fprintf(out,"      integer(SQLUSMALLINT_KIND), parameter::\n");
  fprintf(out,"     -                       SQL_AUTOCOMMIT = %i\n", SQL_AUTOCOMMIT);
  fprintf(out,"      integer(SQLUINTEGER_KIND),  parameter::\n");
  fprintf(out,"     -                    SQL_AUTOCOMMIT_ON = %i\n", SQL_AUTOCOMMIT); 
  fprintf(out,"      integer(SQLUINTEGER_KIND),  parameter::\n");
  fprintf(out,"     -                  SQL_DRIVER_NOPROMPT = %i\n", SQL_DRIVER_NOPROMPT); 
  fprintf(out,"      integer(SQLUSMALLINT_KIND), parameter::\n");
  fprintf(out,"     -                  SQL_DRIVER_COMPLETE = %i\n", SQL_DRIVER_COMPLETE);
  fprintf(out,"      integer(SQLUSMALLINT_KIND), parameter::\n");
  fprintf(out,"     -                      SQL_ACCESS_MODE = %i\n", SQL_ACCESS_MODE);
  fprintf(out,"      integer(SQLUINTEGER_KIND),  parameter::\n");
  fprintf(out,"     -                  SQL_MODE_READ_WRITE = %i\n", SQL_MODE_READ_WRITE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                             SQL_CHAR = %i\n", SQL_CHAR);
  fprintf(out,"      integer(SQLUSMALLINT_KIND), parameter::\n");
  fprintf(out,"     -                        SQL_DBMS_NAME = %i\n", SQL_DBMS_NAME);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                        SQL_DESC_NAME = %i\n", SQL_DESC_NAME);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                        SQL_DESC_TYPE = %i\n", SQL_DESC_TYPE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                           SQL_DOUBLE = %i\n", SQL_DOUBLE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                          SQL_INTEGER = %i\n", SQL_INTEGER);
  fprintf(out,"      integer(SQLHANDLE_KIND),    parameter::\n");
  fprintf(out,"     -                      SQL_NULL_HANDLE = %i\n", SQL_NULL_HANDLE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                      SQL_PARAM_INPUT = %i\n", SQL_PARAM_INPUT);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                             SQL_REAL = %i\n", SQL_REAL);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                          SQL_VARCHAR = %i\n", SQL_VARCHAR);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                      SQL_LONGVARCHAR = %i\n", SQL_LONGVARCHAR);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                           SQL_C_LONG = %i\n", SQL_INTEGER);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                           SQL_F_CHAR = %i\n", SQL_CHAR);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                          SQL_F_FLOAT = %i\n", SQL_REAL);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                         SQL_F_DOUBLE = %i\n", SQL_DOUBLE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                        SQL_F_INTEGER = %i\n", SQL_INTEGER);  
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                    SQL_SIGNED_OFFSET = %i\n", SQL_SIGNED_OFFSET); 
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                  SQL_UNSIGNED_OFFSET = %i\n", SQL_UNSIGNED_OFFSET);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                          SQL_F_SLONG = %i\n", SQL_C_LONG+SQL_SIGNED_OFFSET);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                          SQL_F_ULONG = %i\n", SQL_C_LONG+SQL_UNSIGNED_OFFSET); 
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                       SQL_FETCH_NEXT = %i\n", SQL_FETCH_NEXT);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                      SQL_FETCH_FIRST = %i\n", SQL_FETCH_FIRST);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                       SQL_FETCH_LAST = %i\n", SQL_FETCH_LAST);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                      SQL_FETCH_PRIOR = %i\n", SQL_FETCH_PRIOR);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                   SQL_FETCH_ABSOLUTE = %i\n", SQL_FETCH_ABSOLUTE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                   SQL_FETCH_RELATIVE = %i\n", SQL_FETCH_RELATIVE);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                           SQL_COMMIT = %i\n", SQL_COMMIT);
  fprintf(out,"      integer(SQLSMALLINT_KIND),  parameter::\n");
  fprintf(out,"     -                         SQL_ROLLBACK = %i\n", SQL_ROLLBACK);
  fprintf(out,"\nC----- END SEGMENT\n");
  fclose(out);
  
  /*
     Interface blocks for Fotran/C calls - this approach causes difficulties for some calls
     that return pointers to arrays of different types. The Intel ifort compiler complains
     about different types. It is being bypassed in favor of the compiler-dependent
     calling pattern shown in fvsSQL.c - DR/ESSA.
  */

  /*
  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLEndTran(HT,H,CT)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlendtran_'::fvsSQLEndTran\n");
  fprintf(out2,"           integer(%i) HT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) H\n",  sizeof(SQLHANDLE_KIND));
  fprintf(out2,"           integer(%i) CT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLDisconnect(H)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqldisconnect_'::fvsSQLDisconnect\n");
  fprintf(out2,"           integer(%i) H\n", sizeof(SQLHDBC_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLFreeHandle(HT,H)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlfreehandle_'::fvsSQLFreeHandle\n");
  fprintf(out2,"           integer(%i) HT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) H\n", sizeof(SQLHANDLE_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLAllocHandle(HT,IH,OHP)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlallochandle_'::fvsSQLAllocHandle\n");
  fprintf(out2,"           integer(%i) HT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) IH\n", sizeof(SQLHANDLE_KIND));
  fprintf(out2,"           integer(%i) OHP\n", sizeof(SQLHANDLE_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLExecDirect(SH,ST,TL)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlexecdirect_'::fvsSQLExecDirect\n");
  fprintf(out2,"           integer(%i) SH\n", sizeof(SQLHSTMT_KIND));
  fprintf(out2,"           character(%i) ST\n", sizeof(SQLCHAR_KIND));
  fprintf(out2,"           integer(%i) TL\n", sizeof(SQLINTEGER_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLCloseCursor(SH)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlclosecursor_'::fvsSQLCloseCursor\n");
  fprintf(out2,"           integer(%i) SH\n", sizeof(SQLHSTMT_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLBindParameter(SH,PN,IOT,VT,PT,CS,\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"     >    DD,PVP,BL,SLI)\n");
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlbindparameter_'::fvsSQLBindParameter\n");
  fprintf(out2,"           integer(%i) SH\n", sizeof(SQLHSTMT_KIND));
  fprintf(out2,"           integer(%i) PN\n", sizeof(SQLUSMALLINT_KIND));
  fprintf(out2,"           integer(%i) IOT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) VT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) PT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) CS\n", sizeof(SQLULEN_KIND));
  fprintf(out2,"           integer(%i) DD\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) PVP\n", sizeof(SQLPOINTER_KIND)); 
  fprintf(out2,"           integer(%i) BL\n", sizeof(SQLLEN_KIND));
  fprintf(out2,"           integer(%i) SLI\n", sizeof(SQLLEN_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");

  fprintf(out2,"      INTERFACE\n");
  fprintf(out2,"        integer(%i) function fvsSQLBindCol(SH,CN,TT,TVP,BL,SLI)\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"        !dec$ attributes alias:'_fvssqlbindcol_'::fvsSQLBindCol\n");
  fprintf(out2,"           integer(%i) SH\n", sizeof(SQLHSTMT_KIND));
  fprintf(out2,"           integer(%i) CN\n", sizeof(SQLUSMALLINT_KIND));
  fprintf(out2,"           integer(%i) TT\n", sizeof(SQLSMALLINT_KIND));
  fprintf(out2,"           integer(%i) TVP\n", sizeof(SQLPOINTER_KIND));
  fprintf(out2,"           integer(%i) BL\n", sizeof(SQLLEN_KIND));
  fprintf(out2,"           integer(%i) SLI\n", sizeof(SQLLEN_KIND));
  fprintf(out2,"        end function\n");
  fprintf(out2,"      end interface\n\n");
  
  fclose(out2);
  */
  exit(0);
}

