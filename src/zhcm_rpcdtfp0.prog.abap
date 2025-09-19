*---------------------------------------------------------------------*

REPORT zhcm_rpcdtfp0 MESSAGE-ID pn USING DATABASE pnp.
*---------------------------------------------------------------------*
*  Daten-Definition                                                   *
*---------------------------------------------------------------------*
DATA: molga LIKE t001p-molga VALUE '19'.

INCLUDE rpc2rx29.

INCLUDE rpc2rx39.

INCLUDE rpc2rx02.

INCLUDE rpc2rpp0.

*INCLUDE RPC2RDD0.

SELECTION-SCREEN BEGIN OF BLOCK test1 WITH FRAME TITLE TEXT-009.
PARAMETERS: stor LIKE rpcdtbd0-stor   DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK test1.
*---------------------------------------------------------------------*
*  Programm                                                           *
*---------------------------------------------------------------------*
INCLUDE rpcdto00.

INCLUDE rpcdtmp0.

*---------------------------------------------------------------------
*  Ende des Programms
*---------------------------------------------------------------------
