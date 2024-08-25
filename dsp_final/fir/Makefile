#firpipe:
	#rm -rf xsim.dir/ *.log *.pb *.jou *.wdb
	#xvlog -f ./include.rtl.list.xsim ./tb/fir_pipe_tb.v
	#xelab -top fir_pipe_tb -snapshot fir_pipe_tb_elab
	#xsim fir_pipe_tb_elab -R


#fir:
	#rm -rf xsim.dir/ *.log *.pb *.jou *.wdb
	#xvlog -f ./include.rtl.list.xsim ./tb/fir_tb.v
	#xelab -top fir_tb -snapshot fir_tb_elab
	#xsim fir_tb_elab -R

firtrans:
	rm -rf xsim.dir/ *.log *.pb *.jou *.wdb
	xvlog -f ./include.rtl.list.xsim ./tb/fir_trans_tb.v
	xelab -top fir_trans_tb -snapshot fir_trans_tb_elab
	xsim fir_trans_tb_elab -R


clean:
	rm -rf xsim.dir/ *.log *.pb *.jou *.wdb

