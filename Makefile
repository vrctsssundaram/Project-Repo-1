IVERILOG ?= iverilog
VVP ?= vvp
.PHONY: test clean
test:
	mkdir -p build
	$(IVERILOG) -g2012 -Wall -s tb_axis_l2_policy -o build/sim rtl/axis_l2_policy.sv tb/tb_axis_l2_policy.sv
	$(VVP) build/sim
clean:
	rm -f build/sim
