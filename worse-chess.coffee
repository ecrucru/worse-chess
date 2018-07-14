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
subp.stdout.on('data',
	(data) ->
		# Simplifies the data
		data = data.toString()
		data = data.split("\r").join('')
		data = data.split("\t").join(' ')
		k = data.length
		while true
			data = data.split('  ').join(' ')
			break if data.length is k
			k = data.length

		# Reads each line
		(fromEngine cmd.trim() for cmd in data.split "\n")
		return true
)


###
# Interface from GUI to Adapter
###

process.title = 'Worse Chess for UCI'
process.on('exit',
	(code, signal) ->
		subp.kill()
		return
)
process.stdin.on('readable',
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
		(toEngine cmd.trim() for cmd in data.split "\n")
		return true
)


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
			keys = ['name', 'author']
		when 'setoption'
			keys = ['name', 'value']
		when 'option'
			keys = ['name', 'type', 'default', 'min', 'max']
		when 'info'
			keys = ['cpuload', 'currline', 'currmove', 'currmovenumber', 'depth', 'hashfull', 'multipv', 'nodes', 'nps', 'pv', 'refutation', 'sbhits', 'score', 'seldepth', 'string', 'tbhits', 'time']
		else
			return result

	# Processes
	field = ''
	obj = {}
	for key in keys
		obj[key] = ''
	for i in [1..list.length-1]
		item = list[i].toLowerCase()
		if item in keys
			field = item
			continue
		if field.length is 0
			continue
		if obj[field].length > 0
			obj[field] += ' '
		obj[field] += list[i]
	result.fields = obj
	return result

parseToText = (pParse) ->
	# Checks
	return '' if pParse is null

	# Rebuilds the command line from its elements
	output = pParse.command
	if pParse.fields isnt null
		for key in Object.keys(pParse.fields)
			if pParse.fields[key].length > 0
				output += ' ' + key + ' ' + pParse.fields[key]
	return output

toEngine = (pInput) ->
	# Reads the received command
	parse = parseCommand pInput
	return false if parse is null

	# Processes the special rules
	switch parse.command
		when 'setoption'
			if parse.fields.name is c_mpv_limit and parse.fields.value.length > 0
				multipv = parse.fields.value
				return true											# The option is not forwarded

		when 'isready'
			return false if multipv is null or multipv.length is 0	# The engine will not reply if the option is missing
			toEngine('setoption name MultiPV value ' + multipv)		# The MultiPV is overridden when all the options have been set by the GUI

		when 'go'
			evals = []

		when 'quit'
			setTimeout () ->
				process.exit 0
			, 2000													# Delayed exit event (acks not handled)

	# Sends the command to the engine
	subp.stdin.write(pInput + "\n")
	return true

fromEngine = (pOutput) ->
	# Reads the received command
	parse = parseCommand pOutput
	return false if parse is null

	# Processes
	switch parse.command
		when 'id'
			if parse.fields.name.length > 0
				parse.fields.name += ' (via Worse Chess)'
				pOutput = parseToText parse

		when 'option'
			if parse.fields.name is 'MultiPV'
				multipv = parse.fields.max if parse.fields.max.length > 0

				# Sends the internal option to limit the MultiPV
				parse.fields.name = c_mpv_limit
				parse.fields.default = parse.fields.max
				fromEngine(parseToText parse)

		when 'uciok'
			fromEngine('option name '+c_engine_path+' type string default '+opt_engine)

		when 'info'
			if parse.fields.multipv.length > 0 and parse.fields.pv.length > 0
				evals[parseInt parse.fields.multipv] = parse.fields.pv.split(' ')[0]

		when 'bestmove'
			if evals.length > 0
				pOutput = 'bestmove ' + evals[evals.length-1]

	# Sends the command to the GUI
	console.log pOutput
	return true
