
//Read Corona.csv
(
~csvData = CSVFileReader.readInterpret("C:\\Temp\\corona_data.csv", true, true);

~csvData.size;

~csv_0=Array.fill(~csvData.size,{arg i;~csvData.at(i).asArray.at(0)});
~csv_1=Array.fill(~csvData.size,{arg i;~csvData.at(i).asArray.at(1)});
~csv_2=Array.fill(~csvData.size,{arg i;~csvData.at(i).asArray.at(2)});
~csv_3=Array.fill(~csvData.size,{arg i;~csvData.at(i).asArray.at(3)});
~csv_4=Array.fill(~csvData.size,{arg i;~csvData.at(i).asArray.at(4)});

~todayCnt = ~csv_0;
~clearCnt = ~csv_1.normalize(400, 1000);
~examCnt = ~csv_2.normalize(500, 2000);
~careCnt = ~csv_3.normalize(100, 800);
~negativeCnt = ~csv_4.normalize(-10, 10);
~bamp = ~csv_0.normalize(0.5, 1);
~ban = ~csv_0.normalize(0, 40);
)

~csv_2;
~negativeCnt[1];
//test it in the Synth

(
SynthDef("soundA", {arg dur = 1, amp = 1;
var env, envgen, snap, highPass, output;
	snap = WhiteNoise.ar(2);
	highPass = HPF.ar(snap, SinOsc.kr(XLine.kr(1, 3000, dur), 0, 1, 5000), 1);
	env = Env.perc(0.01, dur/4, amp, 10);
	envgen = EnvGen.ar(env, doneAction:2);
	output = Out.ar([0,1], envgen * highPass);
}).load(s)
);
Synth(\soundA);

(
SynthDef("soundB", {arg freq = 30, dur = 1, amp = 1;
var ampEnv, lowPass, output;
	ampEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: dur/2), 1, levelScale: 5*amp, doneAction:2);
	lowPass = LPF.ar(in: WhiteNoise.ar(2), freq: 100)*ampEnv;
	output = Out.ar([0,1], SinOsc.ar(freq, 0, ampEnv) + lowPass);
}).load(s);
);
Synth(\soundB, [\freq, 500]);

(
SynthDef(\soundC, {arg freq=440, carPartial=1, modPartial=1, index=3, mul=0.2, dur=1;
	var mod, car, env;
	mod = SinOsc.ar(freq * modPartial, 0, freq * index );
	car = SinOsc.ar((freq * carPartial) + mod, 0, mul );
	env = EnvGen.ar( Env.perc(0.01, 1), doneAction: 2, timeScale: dur);
	Out.ar([0, 1], car * env)
}).load(s);
)
Synth(\soundC, [\freq, 840]);

(
SynthDef(\soundD,{
	arg freq=880, dur=0.1, amp=1;
	var env, envGen, sine, out;
	env = Env.perc(dur/100, dur);
	envGen = EnvGen.ar(env, doneAction: 2);
	sine = SinOsc.ar(freq, 0, amp);
	out = Out.ar([0,1], sine * envGen);
}).load(s);
)
Synth(\soundD, [\freq, 1000, \dur, 2]);

(
SynthDef("soundE", {arg freq = 30, dur = 1, amp = 1;
var ampEnv, lowPass, output;
	ampEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: dur/2), 1, levelScale: 5*amp, doneAction:2);
	lowPass = HPF.ar(in: WhiteNoise.ar(2), freq: 1000)*ampEnv;
	output = Out.ar([0,1], SinOsc.ar(freq, 0, ampEnv) + lowPass);
}).load(s);
);
Synth(\soundE, [\freq, 1000]);

(
SynthDef("soundF", {arg freq=100, carFreq=1, amp=0.5, dur=1;
	var modulator, carrier, envgen, out;
	modulator = SinOsc.ar(freq, 0, 0.5, 1);
	carrier = SinOsc.ar(carFreq, 0, modulator);
	envgen = EnvGen.ar(Env.perc(dur/100, dur, amp), timeScale: dur, doneAction: 2);
	out = Out.ar([0,1], carrier*envgen);
}
).load(s);
)
Synth(\soundF, [\freq, 1000]);

(
SynthDef("soundG",{arg freq=200, dur=1, amp=1;
	var gaus, osc, out, env, envGen;
	gaus = {WhiteNoise.ar}.dup(12).sum;
	gaus = LPF.ar(BPF.ar(gaus, 50, 1/0.4), freq);

	osc = SinOsc.ar(gaus.linlin(-1, 1, 40, 80), freq, amp) * gaus.squared * 10;
	osc = (osc - 0.35).max(0);
	osc = HPF.ar(osc, freq, dur);
	// env = Env.ar(osc, dur*10, amp, 10);
	out = Out.ar([0,1], osc);
}).load(s);
)
Synth(\soundG);

(
SynthDef("soundI", {arg freq=100, dur=1, amp=0.5;
	var env, envGen, sine, out;
	env = Env.sine(dur);
	envGen = EnvGen.ar(env, doneAction:2);
	sine = SinOsc.ar(freq, 0, amp/2)+
	SinOsc.ar(freq*1.2, 0, amp/4)+
	SinOsc.ar(freq*2.1, 0, amp/6)+
	SinOsc.ar(freq*3.2, 0, amp/8)+
	SinOsc.ar(freq*4.0, 0, amp/10);

	out = Out.ar([0,1], sine * envGen);
}).load(s);
)
Synth(\soundI, [\freq, 500]);

(
{
	arg dur = 1;
	var trigs, durscale, son, resfreq;
	trigs = Dust.kr(1);
	// durscale = TRand.kr(1, 1.5, trigs);
	durscale = 0.5;
	resfreq = TExpRand.kr(100, 1000, trigs);
	son = WhiteNoise.ar * EnvGen.ar(Env.perc(dur, dur/100, curve: 0), trigs, timeScale: durscale);
	son = son + BPF.ar(son, resfreq, 20);
}.play
)

(
SynthDef(\soundH, { arg freq = 100, dur = 1, amp = 1;
	var carrierLvl=0.5, modulatorRatio=5, modulatorIndex=1.5, outputAmp=0.2, sig, out=0, env;
	// the simple FM core
	sig = LFSaw.ar(freq, 1, 0.5, 0.5) * carrierLvl;
	sig = sig + SinOsc.ar(freq * modulatorRatio) * modulatorIndex;
	sig = cos( sig * 2pi) * outputAmp * amp;
	env = EnvGen.ar( Env.perc(dur, dur/100), doneAction: 2);
	Out.ar(out, env * sig);
},1!5).add;
)
Synth(\soundH,[\freq, 600]);



// Array test



// b = Buffer.read(s, "C:\\Temp\\Alien.wav");
b = Buffer.read(s, "C:\\Temp\\Telegram.wav");


b.play;
(
SynthDef.new(\particles_mouse, {arg dur=1,amp = 1, bufnum, rate, pan = 0;
var playback, env, output;
	playback = PlayBuf.ar(numChannels: 2,
		bufnum: bufnum,
		rate: rate,
		loop: 1,
		doneAction:2);
	env = EnvGen.ar(Env.sine(dur), doneAction: 2);
output = Out.ar(0, Pan2.ar((env * playback) * amp, pan));
}).load(s);
)

Synth(\particles_mouse, [\bufnum, b.bufnum, \rate, ~negativeCnt[200],\pan, 1.0.rand2, \dur, 1]);
Synth(\particles_mouse, [\bufnum, b.bufnum, \pan, ~negativeCnt[60], \dur, 1]);
~nagativeCnt[2].postln;
(
var st = 1/8;
Routine({
	var run = 1;
    var i = 0;
	var cnt = 0;
    while {
		if (i>270) {
			cnt = rand(2);
		}{
			cnt = rand(4);
		};
		i = i + {cnt}.sum(1);
		i<=~todayCnt.size; // if it is not nil, excute the Function
    } {
		(cnt*st).wait;
		Synth(\soundB, [freq: ~todayCnt[i], dur: 1/8*run, amp: 1.2]);
		Post << "a "<< i << "\n";
		(run*st).yield;
		i = i + run;
	}
}).play;

Routine({
	var run = 32;
    var i = 0;
	var cnt = 0;
    while {
		cnt = 1+rand(4);
		i = i + {cnt}.sum(1);
		i<=~negativeCnt.size; // if it is not nil, excute the Function
    } {
		(cnt*st).wait;
		Synth(\soundF, [freq: ~clearCnt[i], dur: 1/8*run, amp: 0.15]);
		Post << "b " << i << "\n" ;
		(run*st).yield;
		i = i + run;
	}
}).play;


Routine({
	var run = 16;
    var i = 0;
	var cnt = 0;
    while {
		cnt = 1+rand(16);
		i = i + {cnt}.sum(1);
		i<=~clearCnt.size; // if it is not nil, excute the Function
    } {
		(cnt*st).wait;
		Synth(\soundE, [freq: ~examCnt[i], dur: 1/8*run, amp: 0.03]);
		Post << "c " << i << "\n" ;
		(run*st).yield;
		i = i + run;
	}
}).play;

Routine({
	var run = 32;
    var i = 0;
	var cnt = 0;
    while {
		cnt = 15+rand(1);
		i = i + {cnt}.sum(1);
		i<=~clearCnt.size; // if it is not nil, excute the Function
    } {
		(cnt*st).wait;
		Synth(\soundH, [freq: ~careCnt[i], dur: 1/8*run, amp: 0.2]);
		Post << "d " << i << "\n" ;
		(run*st).yield;
		i = i + run;
	}
}).play;


Routine({
	var run = 8;
    var i = 0;
	var cnt = 0;
    while {
		// cnt = 32 - ~ban[i].asInteger;
		cnt = 32+rand(16);
		i = i + {cnt}.sum(1);
		i<=~clearCnt.size; // if it is not nil, excute the Function
    } {
		(cnt*st).wait;
		Synth(\particles_mouse, [\bufnum, b.bufnum, \rate, ~negativeCnt[i], \dur, 1/8*run, \amp, ~bamp[i]]);

		// Synth(\soundC, [freq: ~negativeCnt[i], dur: 1/8*run, amp: 0.3]);
		Post << "e " << i << "\n" ;
		(run*st).yield;
		i = i + run;
	}
}).play;

)


^q^


