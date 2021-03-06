"use strict"

Chromath = require "Chromath"
grunt = require "grunt"
colorDiff = require "color-difference"

targetColor = ""
replacementColor = ""
maxDiff = 0

module.exports.init = (instructions) ->
	# replace/set (COLOR) with/to (COLOR) ~(DEVIATION)%
	unless matches = instructions.match(/^\S+ (\S+) (?:with|to) (\S+)(?: ~(\d?\d)%)?$/)
		throw new Error "Invalid instructions! Expected format: `replace/set COLOR with/to NEWCOLOR`"

	if ~["*","all","everything"].indexOf matches[1]
		targetColor = "everything"
	else
		unless targetColor = new Chromath(matches[1])
			grunt.log.warn "`#{matches[1]}` is not a valid color"

	unless replacementColor = new Chromath(matches[2])
		grunt.log.warn "`#{matches[2]}` is not a valid color"

	if matches[3] && targetColor != "everything"
		grunt.log.warn "Warning: approximate color matching is buggy, and the final format is likely to change. Proceed with caution!"
		maxDiff = ~~matches[3] # cast to int

	true

module.exports.processColor = (color) ->
	if targetColor == "everything" || color.toHexString() == targetColor.toHexString()
		return replacementColor

	if maxDiff > 0
		# Using EuclideanDistance until LAB conversion is fixed in node-color-difference.
		diff = colorDiff.compare(color.toHexString(), targetColor.toHexString(), "EuclideanDistance")

		if diff < maxDiff
			grunt.verbose.writeln "(diff #{diff.toFixed(3)} < #{maxDiff})"
			return replacementColor
		else
			grunt.verbose.writeln "(ignoring, diff #{diff.toFixed(3)} > #{maxDiff})"
			return color

	grunt.verbose.writeln "(ignoring #{color.toString()})"
	return color