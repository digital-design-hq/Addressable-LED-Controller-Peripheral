PROJ=ws2812bDemo
CONSTR=versa.lpf
TRELLIS=/usr/share/trellis

all: ${PROJ}.bit

pattern.vh: make_14seg.py text.in
	python3 make_14seg.py < text.in > pattern.vh

%.json: %.v simpleDualPortDualClockMemory.sv WS2812.v out.vh
	yosys -p "synth_ecp5 -json $@ -top top" $<  simpleDualPortDualClockMemory.sv WS2812.v 

%_out.config: %.json
	nextpnr-ecp5 --json $< --lpf ${CONSTR} --textcfg $@ --um5g-45k --package CABGA381

%.bit: %_out.config
	ecppack --svf-rowsize 100000 --svf ${PROJ}.svf $< $@

${PROJ}.svf: ${PROJ}.bit

prog: ${PROJ}.svf
	cp $< ~/shared/ #openocd -f ${TRELLIS}/misc/openocd/ecp5-versa5g.cfg -c "transport select jtag; init; svf $<; exit"

.PHONY: prog
.PRECIOUS: ${PROJ}.json ${PROJ}_out.config
