! -*- fortran -*-
!
! Copyright (c) 2004-2006 The Trustees of Indiana University and Indiana
!                         University Research and Technology
!                         Corporation.  All rights reserved.
! Copyright (c) 2004-2005 The University of Tennessee and The University
!                         of Tennessee Research Foundation.  All rights
!                         reserved.
! Copyright (c) 2004-2005 High Performance Computing Center Stuttgart, 
!                         University of Stuttgart.  All rights reserved.
! Copyright (c) 2004-2005 The Regents of the University of California.
!                         All rights reserved.
! $COPYRIGHT$
! 
! Additional copyrights may follow
! 
! $HEADER$
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! Do ***not*** copy this file to the directory where your Fortran 
! fortran application is compiled unless it is absolutely necessary!  Most
! modern Fortran compilers now support the -I command line flag, which
! tells the compiler where to find .h files (specifically, this one).  For
! example:
!
!      shell$ mpif77 foo.f -o foo -I$OMPI_HOME/include
!
! will probably do the trick (assuming that you have set OMPI_HOME 
! properly).
!
! That being said, OMPI's "mpif77" wrapper compiler should
! automatically include the -I option for you.  The following command
! should be equivalent to the command listed above:
!
!      shell$ mpif77 foo.f -o foo
!
! You should not copy this file to your local directory because it is
! possible that this file will be changed between versions of Open MPI.
! Indeed, this mpif.h is incompatible with the mpif.f of other 
! implementations of MPI.  Using this mpif.h with other implementations 
! of MPI, or with other versions of Open MPI will result in undefined
! behavior (to include incorrect results, segmentation faults, 
! unexplainable "hanging" in your application, etc.).  Always use the
! -I command line option instead (or let mpif77 do it for you).
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      character*100 MPI_HEADER_FILE
      parameter (MPI_HEADER_FILE = 'mpif90_Linux_openmpi.h')

!
! OMPI version
! This file is generated from configure; do not edit it manually.
!
       integer OMPI_MAJOR_VERSION, OMPI_MINOR_VERSION
       integer OMPI_RELEASE_VERSION
       character*32 OMPI_GREEK_VERSION
       character*32 OMPI_SVN_VERSION
       parameter (OMPI_MAJOR_VERSION=1)
       parameter (OMPI_MINOR_VERSION=0)
       parameter (OMPI_RELEASE_VERSION=2)
       parameter (OMPI_GREEK_VERSION="")
       parameter (OMPI_SVN_VERSION="r9571")
!
! MPI version
!
       integer MPI_VERSION, MPI_SUBVERSION

       parameter (MPI_VERSION=2)
       parameter (MPI_SUBVERSION=0)
!
! kind parameters
!
       integer MPI_OFFSET_KIND, MPI_ADDRESS_KIND
       parameter (MPI_OFFSET_KIND=8)
       parameter (MPI_ADDRESS_KIND=8)
!
! misc. constants
!
       integer MPI_ANY_SOURCE, MPI_ANY_TAG
       integer MPI_PROC_NULL, MPI_MAX_PROCESSOR_NAME
       integer MPI_ROOT, MPI_MAX_DATAREP_STRING
       integer MPI_MAX_ERROR_STRING, MPI_UNDEFINED
       integer MPI_CART, MPI_GRAPH, MPI_KEYVAL_INVALID
       integer MPI_STATUS_SIZE, MPI_SOURCE, MPI_TAG, MPI_ERROR
       integer MPI_TAG_UB, MPI_HOST, MPI_IO, MPI_WTIME_IS_GLOBAL
       integer MPI_APPNUM, MPI_LASTUSEDCODE, MPI_UNIVERSE_SIZE
       integer IMPI_CLIENT_SIZE, IMPI_CLIENT_COLOR
       integer IMPI_HOST_SIZE, IMPI_HOST_COLOR
       integer MPI_BSEND_OVERHEAD
       integer MPI_MAX_INFO_KEY, MPI_MAX_INFO_VAL
       integer MPI_MAX_PORT_NAME, MPI_MAX_OBJECT_NAME
       integer MPI_ORDER_C, MPI_ORDER_FORTRAN
       integer MPI_DISTRIBUTE_BLOCK, MPI_DISTRIBUTE_CYCLIC
       integer MPI_DISTRIBUTE_NONE, MPI_DISTRIBUTE_DFLT_DARG
       integer MPI_TYPECLASS_INTEGER, MPI_TYPECLASS_REAL
       integer MPI_TYPECLASS_COMPLEX
       integer MPI_SEEK_SET, MPI_SEEK_CUR, MPI_SEEK_END 
       integer MPI_MODE_CREATE
       integer MPI_MODE_RDONLY, MPI_MODE_WRONLY, MPI_MODE_RDWR
       integer MPI_MODE_DELETE_ON_CLOSE, MPI_MODE_UNIQUE_OPEN
       integer MPI_MODE_EXCL, MPI_MODE_APPEND, MPI_MODE_SEQUENTIAL
       integer MPI_DISPLACEMENT_CURRENT
       

       parameter (MPI_ANY_SOURCE=-1)
       parameter (MPI_ANY_TAG=-1)
       parameter (MPI_PROC_NULL=-2)
       parameter (MPI_ROOT=-4)
       parameter (MPI_MAX_PROCESSOR_NAME=255)
       parameter (MPI_MAX_ERROR_STRING=255)
       parameter (MPI_MAX_DATAREP_STRING=128)
       parameter (MPI_UNDEFINED=-32766)
       parameter (MPI_CART=1)
       parameter (MPI_GRAPH=2)
       parameter (MPI_KEYVAL_INVALID=-1)
       parameter (MPI_STATUS_SIZE=5)
       parameter (MPI_SOURCE=1)
       parameter (MPI_TAG=2)
       parameter (MPI_ERROR=3)
       parameter (MPI_TAG_UB=0)
       parameter (MPI_HOST=1)
       parameter (MPI_IO=2)
       parameter (MPI_WTIME_IS_GLOBAL=3)
       parameter (MPI_APPNUM=4)
       parameter (MPI_LASTUSEDCODE=5)
       parameter (MPI_UNIVERSE_SIZE=6)
       
       
       
       parameter (IMPI_CLIENT_SIZE=10)
       parameter (IMPI_CLIENT_COLOR=11)
       parameter (IMPI_HOST_SIZE=12)
       parameter (IMPI_HOST_COLOR=13)

       parameter (MPI_BSEND_OVERHEAD=128)
       parameter (MPI_MAX_INFO_KEY=35)
       parameter (MPI_MAX_INFO_VAL=255)
       parameter (MPI_MAX_PORT_NAME=35)
       parameter (MPI_MAX_OBJECT_NAME=63)
       parameter (MPI_ORDER_C=0)
       parameter (MPI_ORDER_FORTRAN=1)
       parameter (MPI_DISTRIBUTE_BLOCK=0)
       parameter (MPI_DISTRIBUTE_CYCLIC=1)
       parameter (MPI_DISTRIBUTE_NONE=2)
       parameter (MPI_DISTRIBUTE_DFLT_DARG=-1)
       parameter (MPI_TYPECLASS_INTEGER=1)
       parameter (MPI_TYPECLASS_REAL=2)
       parameter (MPI_TYPECLASS_COMPLEX=3)
       parameter (MPI_SEEK_SET=600)
       parameter (MPI_SEEK_CUR=602)
       parameter (MPI_SEEK_END=604)
       parameter (MPI_MODE_CREATE=1)
       parameter (MPI_MODE_RDONLY=2)
       parameter (MPI_MODE_WRONLY=4)
       parameter (MPI_MODE_RDWR=8)
       parameter (MPI_MODE_DELETE_ON_CLOSE=16)
       parameter (MPI_MODE_UNIQUE_OPEN=32)
       parameter (MPI_MODE_EXCL=64)
       parameter (MPI_MODE_APPEND=128)
       parameter (MPI_MODE_SEQUENTIAL=256)
       parameter (MPI_DISPLACEMENT_CURRENT=-54278278)
!
! global variables
!
       double complex MPI_BOTTOM, MPI_IN_PLACE
       character MPI_ARGV_NULL(1)
!     MPI_ARGVS_NULL must not be a character array so that we can match
!     an appropriate F90 MPI bindings interface function; see comments
!     in mpi-f90-interfaces.h for a full explanation.
       integer MPI_ARGVS_NULL
!     These must be integer arrays so that we can match the proper
!     prototypes in the F90 MPI bindings.
       integer MPI_ERRCODES_IGNORE(1)
       integer MPI_STATUS_IGNORE(MPI_STATUS_SIZE)
       integer MPI_STATUSES_IGNORE(MPI_STATUS_SIZE)

       common/mpi_fortran_bottom/MPI_BOTTOM
       common/mpi_fortran_in_place/MPI_IN_PLACE
       common/mpi_fortran_argv_null/MPI_ARGV_NULL
       common/mpi_fortran_argvs_null/MPI_ARGVS_NULL
       common/mpi_fortran_errcodes_ignore/MPI_ERRCODES_IGNORE
       common/mpi_fortran_status_ignore/MPI_STATUS_IGNORE
       common/mpi_fortran_statuses_ignore/MPI_STATUSES_IGNORE
!
! NULL "handles" (indices)
!
       integer MPI_GROUP_NULL, MPI_COMM_NULL, MPI_DATATYPE_NULL
       integer MPI_REQUEST_NULL, MPI_OP_NULL, MPI_ERRHANDLER_NULL
       integer MPI_INFO_NULL
       

       parameter (MPI_GROUP_NULL=0)
       parameter (MPI_COMM_NULL=2)
       parameter (MPI_DATATYPE_NULL=0)
       parameter (MPI_REQUEST_NULL=0)
       parameter (MPI_OP_NULL=0)
       parameter (MPI_ERRHANDLER_NULL=0)
       parameter (MPI_INFO_NULL=0)
       
!
! MPI_Init_thread constants
!
       integer MPI_THREAD_SINGLE, MPI_THREAD_FUNNELED
       integer MPI_THREAD_SERIALIZED, MPI_THREAD_MULTIPLE

       parameter (MPI_THREAD_SINGLE=0)
       parameter (MPI_THREAD_FUNNELED=1)
       parameter (MPI_THREAD_SERIALIZED=2)
       parameter (MPI_THREAD_MULTIPLE=3)
!
! error classes
!
       integer MPI_SUCCESS                    
       integer MPI_ERR_BUFFER                
       integer MPI_ERR_COUNT                 
       integer MPI_ERR_TYPE                  
       integer MPI_ERR_TAG                   
       integer MPI_ERR_COMM                  
       integer MPI_ERR_RANK                  
       integer MPI_ERR_REQUEST               
       integer MPI_ERR_ROOT                  
       integer MPI_ERR_GROUP                 
       integer MPI_ERR_OP                    
       integer MPI_ERR_TOPOLOGY              
       integer MPI_ERR_DIMS                  
       integer MPI_ERR_ARG                   
       integer MPI_ERR_UNKNOWN               
       integer MPI_ERR_TRUNCATE              
       integer MPI_ERR_OTHER                 
       integer MPI_ERR_INTERN                
       integer MPI_ERR_IN_STATUS             
       integer MPI_ERR_PENDING               
       integer MPI_ERR_ACCESS                
       integer MPI_ERR_AMODE                 
       integer MPI_ERR_ASSERT                
       integer MPI_ERR_BAD_FILE              
       integer MPI_ERR_BASE                  
       integer MPI_ERR_CONVERSION            
       integer MPI_ERR_DISP                  
       integer MPI_ERR_DUP_DATAREP           
       integer MPI_ERR_FILE_EXISTS           
       integer MPI_ERR_FILE_IN_USE           
       integer MPI_ERR_FILE                  
       integer MPI_ERR_INFO_KEY              
       integer MPI_ERR_INFO_NOKEY            
       integer MPI_ERR_INFO_VALUE            
       integer MPI_ERR_INFO                  
       integer MPI_ERR_IO                    
       integer MPI_ERR_KEYVAL                
       integer MPI_ERR_LOCKTYPE              
       integer MPI_ERR_NAME                  
       integer MPI_ERR_NO_MEM                
       integer MPI_ERR_NOT_SAME              
       integer MPI_ERR_NO_SPACE              
       integer MPI_ERR_NO_SUCH_FILE          
       integer MPI_ERR_PORT                  
       integer MPI_ERR_QUOTA                 
       integer MPI_ERR_READ_ONLY             
       integer MPI_ERR_RMA_CONFLICT          
       integer MPI_ERR_RMA_SYNC              
       integer MPI_ERR_SERVICE               
       integer MPI_ERR_SIZE                  
       integer MPI_ERR_SPAWN                 
       integer MPI_ERR_UNSUPPORTED_DATAREP   
       integer MPI_ERR_UNSUPPORTED_OPERATION 
       integer MPI_ERR_WIN                   
       
       integer MPI_ERR_SYSRESOURCE          
       integer MPI_ERR_LASTCODE              
       
       parameter( MPI_SUCCESS                  = 0)
       parameter( MPI_ERR_BUFFER               = 1)
       parameter( MPI_ERR_COUNT                = 2)
       parameter( MPI_ERR_TYPE                 = 3)
       parameter( MPI_ERR_TAG                  = 4)
       parameter( MPI_ERR_COMM                 = 5)
       parameter( MPI_ERR_RANK                 = 6)
       parameter( MPI_ERR_REQUEST              = 7)
       parameter( MPI_ERR_ROOT                 = 8)
       parameter( MPI_ERR_GROUP                = 9)
       parameter( MPI_ERR_OP                   = 10)
       parameter( MPI_ERR_TOPOLOGY             = 11)
       parameter( MPI_ERR_DIMS                 = 12)
       parameter( MPI_ERR_ARG                  = 13)
       parameter( MPI_ERR_UNKNOWN              = 14)
       parameter( MPI_ERR_TRUNCATE             = 15)
       parameter( MPI_ERR_OTHER                = 16)
       parameter( MPI_ERR_INTERN               = 17)
       parameter( MPI_ERR_IN_STATUS            = 18)
       parameter( MPI_ERR_PENDING              = 19)
       parameter( MPI_ERR_ACCESS               = 20)
       parameter( MPI_ERR_AMODE                = 21)
       parameter( MPI_ERR_ASSERT               = 22)
       parameter( MPI_ERR_BAD_FILE             = 23)
       parameter( MPI_ERR_BASE                 = 24)
       parameter( MPI_ERR_CONVERSION           = 25)
       parameter( MPI_ERR_DISP                 = 26)
       parameter( MPI_ERR_DUP_DATAREP          = 27)
       parameter( MPI_ERR_FILE_EXISTS          = 28)
       parameter( MPI_ERR_FILE_IN_USE          = 29)
       parameter( MPI_ERR_FILE                 = 30)
       parameter( MPI_ERR_INFO_KEY             = 31)
       parameter( MPI_ERR_INFO_NOKEY           = 32)
       parameter( MPI_ERR_INFO_VALUE           = 33)
       parameter( MPI_ERR_INFO                 = 34)
       parameter( MPI_ERR_IO                   = 35)
       parameter( MPI_ERR_KEYVAL               = 36)
       parameter( MPI_ERR_LOCKTYPE             = 37)
       parameter( MPI_ERR_NAME                 = 38)
       parameter( MPI_ERR_NO_MEM               = 39)
       parameter( MPI_ERR_NOT_SAME             = 40)
       parameter( MPI_ERR_NO_SPACE             = 41)
       parameter( MPI_ERR_NO_SUCH_FILE         = 42)
       parameter( MPI_ERR_PORT                 = 43)
       parameter( MPI_ERR_QUOTA                = 44)
       parameter( MPI_ERR_READ_ONLY            = 45)
       parameter( MPI_ERR_RMA_CONFLICT         = 46)
       parameter( MPI_ERR_RMA_SYNC             = 47)
       parameter( MPI_ERR_SERVICE              = 48)
       parameter( MPI_ERR_SIZE                 = 49)
       parameter( MPI_ERR_SPAWN                = 50)
       parameter( MPI_ERR_UNSUPPORTED_DATAREP  = 51)
       parameter( MPI_ERR_UNSUPPORTED_OPERATION= 52)
       parameter( MPI_ERR_WIN                  = 53)
       
       parameter( MPI_ERR_SYSRESOURCE          = -2)
       parameter( MPI_ERR_LASTCODE             = 54)

!
! comparison results
!
       integer MPI_IDENT, MPI_CONGRUENT, MPI_SIMILAR, MPI_UNEQUAL

       parameter (MPI_IDENT=0)
       parameter (MPI_CONGRUENT=1)
       parameter (MPI_SIMILAR=2)
       parameter (MPI_UNEQUAL=3)
!
! datatype combiners
!
       integer MPI_COMBINER_NAMED
       integer MPI_COMBINER_DUP
       integer MPI_COMBINER_CONTIGUOUS
       integer MPI_COMBINER_VECTOR
       integer MPI_COMBINER_HVECTOR_INTEGER
       integer MPI_COMBINER_HVECTOR
       integer MPI_COMBINER_INDEXED
       integer MPI_COMBINER_HINDEXED_INTEGER
       integer MPI_COMBINER_HINDEXED
       integer MPI_COMBINER_INDEXED_BLOCK
       integer MPI_COMBINER_STRUCT_INTEGER
       integer MPI_COMBINER_STRUCT
       integer MPI_COMBINER_SUBARRAY
       integer MPI_COMBINER_DARRAY
       integer MPI_COMBINER_F90_REAL
       integer MPI_COMBINER_F90_COMPLEX
       integer MPI_COMBINER_F90_INTEGER
       integer MPI_COMBINER_RESIZED

       parameter (MPI_COMBINER_NAMED=0)
       parameter (MPI_COMBINER_DUP=1)
       parameter (MPI_COMBINER_CONTIGUOUS=2)
       parameter (MPI_COMBINER_VECTOR=3)
       parameter (MPI_COMBINER_HVECTOR_INTEGER=4)
       parameter (MPI_COMBINER_HVECTOR=5)
       parameter (MPI_COMBINER_INDEXED=6)
       parameter (MPI_COMBINER_HINDEXED_INTEGER=7)
       parameter (MPI_COMBINER_HINDEXED=8)
       parameter (MPI_COMBINER_INDEXED_BLOCK=9)
       parameter (MPI_COMBINER_STRUCT_INTEGER=10)
       parameter (MPI_COMBINER_STRUCT=11)
       parameter (MPI_COMBINER_SUBARRAY=12)
       parameter (MPI_COMBINER_DARRAY=13)
       parameter (MPI_COMBINER_F90_REAL=14)
       parameter (MPI_COMBINER_F90_COMPLEX=15)
       parameter (MPI_COMBINER_F90_INTEGER=16)
       parameter (MPI_COMBINER_RESIZED=17)
!
! lookup table indices
!
       integer MPI_COMM_WORLD, MPI_COMM_SELF
       integer MPI_GROUP_EMPTY
       integer MPI_ERRORS_ARE_FATAL, MPI_ERRORS_RETURN

       parameter (MPI_COMM_WORLD=0)
       parameter (MPI_COMM_SELF=1)
       parameter (MPI_GROUP_EMPTY=1)
       parameter (MPI_ERRORS_ARE_FATAL=1)
       parameter (MPI_ERRORS_RETURN=2)

       integer MPI_BYTE, MPI_PACKED, MPI_UB, MPI_LB
       integer MPI_CHARACTER, MPI_LOGICAL
       integer MPI_INTEGER, MPI_INTEGER1, MPI_INTEGER2, MPI_INTEGER4
       integer MPI_INTEGER8, MPI_INTEGER16
       integer MPI_REAL, MPI_REAL4, MPI_REAL8, MPI_REAL16
       integer MPI_DOUBLE_PRECISION
       integer MPI_COMPLEX, MPI_COMPLEX8, MPI_COMPLEX16, MPI_COMPLEX32
       integer MPI_DOUBLE_COMPLEX
       integer MPI_2REAL, MPI_2DOUBLE_PRECISION, MPI_2INTEGER

       parameter (MPI_BYTE=1)
       parameter (MPI_PACKED=2)
       parameter (MPI_UB=3)
       parameter (MPI_LB=4)
       parameter (MPI_CHARACTER=5)
       parameter (MPI_LOGICAL=6)
       parameter (MPI_INTEGER=7)
       parameter (MPI_INTEGER1=8)
       parameter (MPI_INTEGER2=9)
       parameter (MPI_INTEGER4=10) 
       parameter (MPI_INTEGER8=11)  
       parameter (MPI_INTEGER16=12)
       parameter (MPI_REAL=13+4*iRealPrec)
       parameter (MPI_REAL4=14)
       parameter (MPI_REAL8=15)
       parameter (MPI_REAL16=16)
       parameter (MPI_DOUBLE_PRECISION=17)
       parameter (MPI_COMPLEX=18+4*iRealPrec)
       parameter (MPI_COMPLEX8=19)
       parameter (MPI_COMPLEX16=20)
       parameter (MPI_COMPLEX32=21)
       parameter (MPI_DOUBLE_COMPLEX=22)
       parameter (MPI_2REAL=23)
       parameter (MPI_2DOUBLE_PRECISION=24)
       parameter (MPI_2INTEGER=25)

       integer MPI_MAX, MPI_MIN, MPI_SUM, MPI_PROD, MPI_LAND
       integer MPI_BAND, MPI_LOR, MPI_BOR, MPI_LXOR, MPI_BXOR
       integer MPI_MAXLOC, MPI_MINLOC, MPI_REPLACE

       parameter (MPI_MAX=1)
       parameter (MPI_MIN=2)
       parameter (MPI_SUM=3)
       parameter (MPI_PROD=4)
       parameter (MPI_LAND=5)
       parameter (MPI_BAND=6)
       parameter (MPI_LOR=7)
       parameter (MPI_BOR=8)
       parameter (MPI_LXOR=9)
       parameter (MPI_BXOR=10)
       parameter (MPI_MAXLOC=11)
       parameter (MPI_MINLOC=12)
       parameter (MPI_REPLACE=13)
!
! attribute functions
!
       external MPI_NULL_COPY_FN, MPI_NULL_DELETE_FN
       external MPI_COMM_NULL_COPY_FN, MPI_COMM_NULL_DELETE_FN
       external MPI_TYPE_NULL_COPY_FN, MPI_TYPE_NULL_DELETE_FN
       external MPI_DUP_FN, MPI_COMM_DUP_FN, MPI_TYPE_DUP_FN
       
       
       
!
! double precision functions
!
      double precision MPI_WTIME, MPI_WTICK , PMPI_WTICK, PMPI_WTIME
      external MPI_WTIME, MPI_WTICK , PMPI_WTICK, PMPI_WTIME
