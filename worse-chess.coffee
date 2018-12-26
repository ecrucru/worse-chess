###
	Worse Chess - Any decent UCI chess engine will now play a worse/the worst chess move
	Copyright (C) 2018, ecrucru

		https://github.com/ecrucru/worse-chess/

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as
	published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.

	@license
###


###
# Changeable settings
###

opt_engine = 'C:\\path\\engine.exe'
opt_arguments = []									# Example: ["-load", "c:\\path\\script.js"]


###
# Global variables
###

spawn = require('child_process').spawn
fs = require 'fs'

c_mpv_limit = 'WorseChess_MultiPV_Limit'
c_engine_path = 'WorseChess_Engine_ReadOnly'
multipv = null
evals = []


###
# Interface between Adapter and Engine
###

if ('\\' in opt_engine or '//' in opt_engine) and not fs.existsSync opt_engine
	throw 'Error : in the script, please define the filename of the engine.'
subp = spawn opt_engine, opt_arguments
subp.stdout.lastChunk = ''
subp.stdout.on 'data',
	(data) ->
		# Simplifies the data
		data = @lastChunk + data.toString()
		if !data.endsWith "\n"									# The last command is truncated
			p = data.lastIndexOf "\n"
			if p is -1
				@lastChunk = data
				return true
			else
				p++
				@lastChunk = data.substring p
				data = data.substring 0, p
		else
			@lastChunk = ''
		data = data.split("\r").join('')
		data = data.split("\t").join(' ')
		k = data.length
		while true
			data = data.split('  ').join(' ')
			break if data.length is k
			k = data.length

		# Reads each line
		fromEngine cmd.trim() for cmd in data.split "\n"
		return true


###
# Interface from GUI to Adapter
###

process.title = 'Worse Chess for UCI'
process.on 'exit',
	(code, signal) ->
		subp.kill()
		return true
process.stdin.on 'readable',
	() ->
		# Input block of data
		data = process.stdin.read()
		return false if data is null
		data = data.toString()

		# Simplifies the data
		data = data.split("\r").join('')
		data = data.split("\t").join(' ')
		k = data.length;
		while true
			data = data.split('  ').join(' ')
			break if data.length is k
			k = data.length

		# Reads each line
		toEngine cmd.trim() for cmd in data.split "\n"
		return true


###
# Functions
###

parseCommand = (pCommand) ->
	# Splits
	return null if pCommand is null or pCommand.length is 0
	list = pCommand.split ' '

	# Settings for the modified commands
	result =
		command : list[0].toLowerCase()
		fields  : null
	switch result.command
		when 'id'
			keys = ['name', 'author', 'description']
		when 'setoption'
			keys = ['name', 'value']
		when 'option'
			keys = ['name', 'type', 'default', 'min', 'max']
		when 'info'
			keys = ['cpuload', 'currline', 'currmove', 'currmovenumber', 'depth', 'hashfull', 'multipv', 'nodes', 'nps', 'pv', 'refutation', 'sbhits', 'score', 'seldepth', 'string', 'tbhits', 'time']
		else
			return result

	# Prepares the result
	if keys.length > 0
		# Initializes all the expectable keys
		field = ''
		obj = {}
		for key in keys
			obj[key] = null

		# Scans each item from the command
		for i in [0..list.length-1]
			item = list[i].toLowerCase()

			# Handles the received key
			if item in keys
				field = item
				if obj[field] is null
					obj[field] = ''
				else
					if Array.isArray obj[field]
						obj[field].push ''							# Handling of the combo with a new item
					else
						obj[field] = [obj[field], '']
				continue

			# Verifies that we are updating a valid key
			if field.length is 0
				continue

			# Appends the value to the key
			if Array.isArray obj[field]
				if obj[field][obj[field].length-1].length > 0
					obj[field][obj[field].length-1] += ' '
				obj[field][obj[field].length-1] += list[i]
			else
				if obj[field].length > 0
					obj[field] += ' '
				obj[field] += list[i]
		result.fields = obj
	return result

parseToText = (pParse) ->
	# Checks
	return '' if pParse is null

	# Rebuilds the command line from its parsed elements
	output = pParse.command
	if pParse.fields isnt null
		for key in Object.keys pParse.fields
			if pParse.fields[key] isnt null
				if Array.isArray pParse.fields[key]
					for v in pParse.fields[key] when v.length > 0
						output += " #{key}" if key != pParse.command
						output += " #{v}"
				else
					output += " #{key}" if key != pParse.command
					v = pParse.fields[key]
					output += " #{v}" if v.length > 0
	return output

toEngine = (pInput) ->
	# Reads the received command
	parse = parseCommand pInput
	return false if parse is null

	# Processes the special rules
	switch parse.command
		when 'setoption'
			if parse.fields.name is c_mpv_limit
				multipv = parse.fields.value if parse.fields.value not in [null, '']
				return true											# The option is not forwarded

		when 'isready'
			return false if multipv is null or multipv.length is 0	# The engine will not reply if the option is missing
			toEngine "setoption name MultiPV value #{multipv}"		# The MultiPV is overridden when all the options have been set by the GUI

		when 'go'
			evals = []

		when 'quit'
			setTimeout () ->
				process.exit 0
			, 2000													# Delayed exit event (acks not handled)

	# Sends the command to the engine
	subp.stdin.write "#{pInput}\n"
	return true

fromEngine = (pOutput) ->
	# Reads the received command
	return false if pOutput.length is 0
	parse = parseCommand pOutput
	return false if parse is null

	# Processes
	## console.log JSON.stringify parse
	switch parse.command
		when 'id'
			if parse.fields.name isnt null
				parse.fields.name += ' (via Worse Chess)'
				pOutput = parseToText parse

		when 'option'
			if parse.fields.name is 'MultiPV'
				multipv = parse.fields.max if parse.fields.max not in [null, '']

				# Sends the internal option to limit the MultiPV
				parse.fields.name = c_mpv_limit
				parse.fields.default = parse.fields.max
				fromEngine parseToText parse

		when 'uciok'
			fromEngine "option name #{c_engine_path} type string default #{opt_engine}"

		when 'info'
			if parse.fields.multipv isnt null and parse.fields.pv isnt null
				evals[parseInt parse.fields.multipv] = parse.fields.pv.split(' ')[0]

		when 'bestmove'
			if evals.length > 0
				pOutput = "bestmove #{evals[evals.length-1]}"

	# Sends the command to the GUI
	console.log pOutput
	return true
