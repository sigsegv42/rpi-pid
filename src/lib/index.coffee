
class PID
	# PID settings
	kp_: 0
	ki_: 0
	kd_: 0
	# auto or manual mode
	mode_: "auto"
	# normal or reverse direction
	direction_: "normal"
	# set value
	sv_: 0
	# parameter value
	pv_: 0
	# in ms - default 0.1s
	sampleFrequency_: 100
	# current integral term
	iterm_: 0
	# [min, max] output range
	outMin_: 0
	outMax_: 255
	lastSample_: 0
	lastPv_: 0
	output_: 0
	# display settings
	dispKp_: 0
	dispKi_: 0
	dispKd_: 0

	constructor: () ->
		@lastSample_ = now - @sampleFrequency_

	compute: () =>
		if @mode_ != "auto"
			false
		# get current time
		# get delta between now and last sample
		delta = now - @lastSample_
		if delta < @sampleFrequency_
			false

		error = @sv_ - @pv_
		@iterm += @ki_ * error

		if @iterm_ > @outMax_
			@iterm_ = @outMax_
		else if @iterm_ < @outMin_
			@iterm_ = @outMin_
		input = @pv_ - @lastPv_
		@output_ = @kp_ * error + @iterm_ - @kd_ * input
		if @output_ > @outMax_
			@output = @outMax_
		else if @output_ < @outMin_
			@output_ = @outMin_
		@lastPv_ = input
		@lastSample_ = delta 
		true

	tune: (kp, ki, kd) =>

		if kp < 0 or ki < 0 or kd < 0
			return
		sampleFreqInSecs = @sampleFrequency_ / 1000

		@dispKp_ = kp
		@dispKi_ = ki
		@dispKd_ = kd

		@kp_ = kp
		@ki_ = ki * sampleFreqInSecs
		@kd_ = kd / sampleFreqInSecs

		if @direction_ == "reverse"
			@kp_ = 0 - @kp_
			@ki_ = 0 - @ki_
			@kd_ = 0 - @kd_

		return

	frequency: (newSampleFrequency) =>
		if newSampleFrequency <= 0
			return
		ratio = newSampleFrequency / @sampleFrequency_
		@ki_ *= ratio
		@kd_ /= ratio
		@sampleFrequency_ = newSampleFrequency
		@

	limit: (min, max) =>
		if min >= max
			@
		@outMin_ = min
		@outMax_ = max
		if @mode_ == "auto"
			if @output_ > @outMax_
				@output_ = @outMax_
			else if @output_ < @outMin_
				@output = @outMin_

			if @iterm_ > @outMax_
				@iterm_ = @outMax_
			else if @iterm_ < @outMin_
				@iterm_ = @outMin_
		@

	direction: (dir) =>
		if @mode_ == "auto" and dir != @direction_
			@kp_ = 0 - @kp_
			@ki_ = 0 - @ki_
			@kd_ = 0 - @kd_
		@direction_ = dir


module.exports.PID = PID
