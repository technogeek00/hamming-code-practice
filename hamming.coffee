# Fun with Hamming Codes
# Practice for CSE 461 Midterm
# By Zachary Cava

convertToBitArray = (data, maxLength = 32) ->
	result = []
	mask = 0x01
	for i in [0 ... maxLength]
		bit = mask & data
		result.unshift(if bit == 0 then 0 else 1)
		mask *= 2
	return result

largestPowerForNum = (num) ->
	power = 0
	while num >= 1
		power++
		num /= 2
	return power

simulateNetwork = (arr) ->
	# only flip bits sometimes
	if Math.random() > 0.20
		# flip random bit
		pos = Math.floor(Math.random() * arr.length)
		arr[pos] += 1
		arr[pos] %= 2
		return pos + 1
	return -1

generateHammingCode = (val) ->
	val = parseInt(val, 10)
	necBinary = largestPowerForNum(val)
	binary = convertToBitArray(val, necBinary + 1)

	addToParityBits = (num, array) ->
		largest = largestPowerForNum(num)
		numBinary = convertToBitArray(num, largest)
		
		power = 1
		for i in [numBinary.length - 1 .. 0]
			if numBinary[i] == 1
				array[power - 1] += array[num - 1]
				array[power - 1] %= 2
			power *= 2

	code = []
	power = 1
	pos = 1
	while binary.length > 0
		if pos == power
			code.push(0)
			power *= 2
		else
			code.push(binary.shift())
			addToParityBits(pos, code)
		pos++

	return code

promptHammingCode = (code) ->
	console.log(" -- Signal Recieved -- ")
	console.log("Coded Message\n")
	message = "    "
	labels  = "    "
	power = 1
	for i in [0 ... code.length]
		message += "  " + code[i] + "  "
		if i + 1 == power
			labels += " p"
			power *= 2
		else
			labels += " m"
		labels += (i + 1) + " "
		if i < 10
			labels += " "
	console.log(message)
	console.log(labels)
	console.log("\nPlease verify the code.")
	console.log("Enter the number of the bit that was flipped (-1 if all are correct): ")

intro = ->
	console.log("The Hamming Story")

	console.log("  One day you were sitting at your computer and chatting with")
	console.log("your friends over IRC. Suddenly your network became very")
	console.log("unreliable and to compensate your friends began sending messages")
	console.log("to you using Hamming encodings. Unfortunetly you forgot to update")
	console.log("your messaging client (again) and it cannot automatically decode")
	console.log("the messages for you. Luckily you are a networks student and know")
	console.log("how the code works!\n")

	console.log("Translate each code as it comes across the wire by either")
	console.log("verifying the message is correct or correcting the bit flipped.")

	console.log("Finish them all to find out what your friends are saying to you!")
	console.log("")


input = process.openStdin()
prompts = 0
NUM_PROMPTS = 10
flippedBit = -1

setupStep = ->
	if prompts < NUM_PROMPTS
		# random number for code, 10 to 30
		val = Math.floor(Math.random() * 20) + 10
		code = generateHammingCode(val)
		flippedBit = simulateNetwork(code)
		promptHammingCode(code)
		prompts++
	else
		console.log("Nice job you've decoded the message!")
		console.log("They say: Good luck on your midterm!")
		console.log("")
		console.log(" -- Terminated --")
		process.exit(0)

promptResponse = (data) ->
	val = parseInt(data, 10)
	if val != flippedBit
		if val == -1
			console.log("Sorry but it looks like a bit has been flipped.\n")
		else
			console.log("That bit looks okay to me.\n")
		console.log("Enter the number of the bit that was flipped (-1 if all are correct): ")
	else
		console.log("Correct! Nice work\n")
		setupStep()

intro()
input.addListener('data', promptResponse)
setupStep()