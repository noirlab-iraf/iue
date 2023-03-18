#  IUETOOLS package - IUE general utilities
#
#  newsips.cl Revision history:
#	 2-Dec-97 by RAShaw	created
#	28-Apr-98 by RAShaw	added infoiue
#	15-May-98 by RAShaw	added itf_trans
#	16-Jul-99 by RAShaw	re-cast mxtomultispec as a compiled task

procedure iuetools()
string mode="al"

begin

	package iuetools

	task infoiue,
	     itf_trans,
	     mxtomultispec,
	     mxexpand		= "iuetools$x_iuetools.e"

	cl()

	hidetask itf_trans
end
