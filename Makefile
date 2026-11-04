IVERILOG ?= iverilog
VVP ?= vvp
.PHONY: test synth synth-fpga clean
test:
	mkdir -p build
	$(IVERILOG) -g2012 -Wall -s tb_axis_l2_policy -o build/sim rtl/axis_l2_policy.sv tb/tb_axis_l2_policy.sv
	$(VVP) build/sim
synth:
	mkdir -p build
	yosys -Q -T -l build/synthesis.log -p 'read_verilog -sv rtl/axis_l2_policy.sv; hierarchy -check -top axis_l2_policy; synth -top axis_l2_policy; stat'
synth-fpga:
	mkdir -p build
	yosys -Q -T -l build/xc7-mapping.log -p 'read_verilog -sv rtl/axis_l2_policy.sv; synth_xilinx -family xc7 -top axis_l2_policy; stat'
clean:
	rm -f build/sim
