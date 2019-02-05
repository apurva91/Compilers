f1 = open("Intermediate.txt").read().splitlines()
f2 = open("temp.asm","w")

temp_regs = { "t0":"A","t1":"B","t2":"C","t3":"D","t4":"E","t5":"H","t6":"L"}

line_ptr = 0

condition = 0


stack = []

compl_label_num = -1
def get_new_compl_label():
	global compl_label_num
	compl_label_num+=1
	return "COMPARE" + str(compl_label_num)

def get_compl_label():
	global compl_label_num
	return "COMPARE" + str(compl_label_num)

ie_label_num = -1
def get_new_ie_label():
	global ie_label_num
	ie_label_num+=1
	return "IFTHEN" + str(ie_label_num)

def get_ie_label():
	global ie_label_num
	return "IFTHEN" + str(ie_label_num)

p_label_num = -1
def get_new_p_label():
	global p_label_num
	p_label_num+=1
	return "POPPED" + str(p_label_num)

def get_p_label():
	global p_label_num
	return "POPPED" + str(p_label_num)

l_label_num = -1
def get_new_l_label():
	global l_label_num
	l_label_num+=1
	return "LOOP" + str(l_label_num)

def get_l_label():
	global l_label_num
	return "LOOP" + str(l_label_num)


def gen_out(com):
	f2.write(com+"\n")

def handle_conditions():
	global line_ptr
	if "<-" in f1[line_ptr]:
		if(f1[line_ptr].split()[0].startswith("_")):
			if(f1[line_ptr].split()[2] == "t0"):
				gen_out("STA "+f1[line_ptr].split()[0])
			else:
				gen_out("PUSH PSW\nMOV A, " + temp_regs[f1[line_ptr].split()[2]] + "\nSTA "+ f1[line_ptr].split()[0] +"\nPOP PSW")
		else:
			if len(f1[line_ptr].split())==3:
				gen_out("MOV " + temp_regs[f1[line_ptr].split()[0]] + ", " + temp_regs[f1[line_ptr].split()[2]])
			else:
				if f1[line_ptr].split()[3] == ">":
					gen_out("MOV L, " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV H, " + temp_regs[f1[line_ptr].split()[4]])
					gen_out("PUSH H \nPUSH PSW \nMOV A, H \nCMP L \nMVI A, 1 \nJNC "+ get_new_compl_label() +" \nMVI A, 0\n" + get_compl_label() + ":")
				elif f1[line_ptr].split()[3] == "<":
					gen_out("MOV H, " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV L, " + temp_regs[f1[line_ptr].split()[4]])
					gen_out("PUSH H \nPUSH PSW \nMOV A, H \nCMP L \nMVI A, 1 \nJNC "+ get_new_compl_label() +" \nMVI A, 0\n" + get_compl_label() + ":")
				elif f1[line_ptr].split()[3] == "==":
					gen_out("MOV H, " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV L, " + temp_regs[f1[line_ptr].split()[4]])
					gen_out("PUSH H \nPUSH PSW \nMOV A, H \nCMP L \nMVI A, 0 \nJZ "+ get_new_compl_label() +" \nMVI A, 1\n" + get_compl_label() + ":")
	elif "=" in f1[line_ptr]:
		if not (f1[line_ptr].split()[2].startswith("_")):
			gen_out("MVI "+  temp_regs[f1[line_ptr].split()[0]] +", " +f1[line_ptr].split()[2])
		else:
			if(f1[line_ptr].split()[0] == "t0"):
				gen_out("LDA "+f1[line_ptr].split()[2])
			else:
				gen_out("PUSH PSW\nLDA " + f1[line_ptr].split()[2] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP PSW")
	line_ptr+=1	


def handle_while():
	global line_ptr, stack
	line_ptr+=1
	label1 = get_new_l_label()
	label2 = get_new_l_label()
	gen_out(label1 + ":")
	while(1):
		if len(f1[line_ptr].split()) == 1:
			gen_out("MVI H, 0\nCMP H\nJNZ " + label2 + "\nPOP PSW \nPOP H")
			stack.append("JMP " + label1 + "\n" + label2 + ":\nPOP PSW\nPOP H\n" + get_p_label() + ":")
			line_ptr+=1
			break
		else:
			handle_conditions()


def handle_if():
	global line_ptr, stack
	line_ptr+=1
	while(1):
		if len(f1[line_ptr].split()) == 1:
			gen_out("MVI H, 0\nCMP H\nJNZ " + get_new_ie_label() + "\nPOP PSW \nPOP H")
			stack.append("JMP " + get_new_p_label() + "\n" + get_ie_label() + ":\nPOP PSW\nPOP H\n" + get_p_label() + ":")
			line_ptr+=1
			break
		else:
			handle_conditions()


def handle_statement():
	global line_ptr
	if "<-" in f1[line_ptr]:
		if(f1[line_ptr].split()[0].startswith("_")):
			if(f1[line_ptr].split()[2] == "t0"):
				gen_out("STA "+f1[line_ptr].split()[0])
			else:
				gen_out("PUSH PSW\nMOV A, " + temp_regs[f1[line_ptr].split()[2]] + "\nSTA "+ f1[line_ptr].split()[0] +"\nPOP PSW")
		else:
			gen_out("MOV " + temp_regs[f1[line_ptr].split()[0]] + ", " + temp_regs[f1[line_ptr].split()[2]])

	elif "+=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			gen_out("ADD " + temp_regs[f1[line_ptr].split()[2]])
		else:
			gen_out("PUSH PSW\nMOV A, "+temp_regs[f1[line_ptr].split()[0]] + "\nADD " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP PSW")
	
	elif "*=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			b = temp_regs[f1[line_ptr].split()[0]]
			c = temp_regs[f1[line_ptr].split()[2]]
			gen_out("PUSH B")
			gen_out("MOV C," + c)
			gen_out("MOV B, A")
			gen_out("MVI A, 0")
			label = get_new_l_label()
			gen_out(label + ":")
			gen_out("ADD B" )
			gen_out("DCR C")
			gen_out("JNZ " + label)
			gen_out("POP B")
		else:
			b = temp_regs[f1[line_ptr].split()[0]]
			c = temp_regs[f1[line_ptr].split()[2]]
			gen_out("PUSH PSW")
			gen_out("MOV A, " + c)
			gen_out("PUSH PSW")			
			gen_out("MVI A, 0")
			label = get_new_l_label()
			gen_out(label + ":")
			gen_out("ADD " + b)
			gen_out("DCR " + c)
			gen_out("JNZ " + label)
			gen_out("MOV " + b + ", A")
			gen_out("POP PSW")
			gen_out("MOV " + c +", A")
			gen_out("POP PSW")
	
	elif "/=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			b = temp_regs[f1[line_ptr].split()[0]]
			c = temp_regs[f1[line_ptr].split()[2]]
			gen_out("PUSH B")
			gen_out("MOV B," + c)
			gen_out("MOV A," + b)
			gen_out("MVI C, 0")
			label = get_new_l_label()
			gen_out(label + ":")
			gen_out("SUB B" )
			gen_out("INR C")
			gen_out("CMP B")
			gen_out("JC " + label)
			gen_out("MOV A, C")
			gen_out("POP B")

		else:
			b = temp_regs[f1[line_ptr].split()[0]]
			c = temp_regs[f1[line_ptr].split()[2]]
			gen_out("PUSH PSW")
			gen_out("PUSH B")
			gen_out("MOV B," + c)
			gen_out("MOV A," + b)
			gen_out("MVI C, 0")
			label = get_new_l_label()
			gen_out(label + ":")
			gen_out("SUB B" )
			gen_out("INR C")
			gen_out("CMP B")
			gen_out("JC " + label)
			gen_out("MOV A, C")
			gen_out("POP B")
			gen_out("MOV " + b + ", A")
			gen_out("POP PSW")




	elif "-=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			gen_out("SUB " + temp_regs[f1[line_ptr].split()[2]])
		else:
			gen_out("PUSH PSW\nMOV A, "+temp_regs[f1[line_ptr].split()[0]] + "\nSUB " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP PSW")

	elif "=" in f1[line_ptr]:
		if not (f1[line_ptr].split()[2].startswith("_")):
			gen_out("MVI " + temp_regs[f1[line_ptr].split()[0]] + ", "+ f1[line_ptr].split()[2])
		else:
			if(f1[line_ptr].split()[0] == "t0"):
				gen_out("LDA "+f1[line_ptr].split()[2])
			else:
				gen_out("PUSH PSW\nLDA " + f1[line_ptr].split()[2] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP PSW")

	line_ptr+=1

def main():
	global line_ptr, stack, f2
	while(1):
		if f1[line_ptr].startswith("if ("):
			handle_if()
		elif f1[line_ptr].startswith("} END") or f1[line_ptr].startswith("BEGIN{"):
			line_ptr+=1
		elif f1[line_ptr].startswith("while ("):
			handle_while()
		elif f1[line_ptr].startswith("}"):
			gen_out(stack.pop())
			line_ptr+=1
		else:
			handle_statement()
		if line_ptr==len(f1):
			break
	gen_out("HLT")
	f2.close()
	f2 = open("temp.asm","r").read().split()
	variables = list(set([x for x in f2 if x.startswith("_")]))
	mapping = {}
	for idx, x in enumerate(variables):
		mapping[x] = str(1000 + idx) + "H"
	f2 = open("temp.asm","r").read()
	for x in variables:
		f2 = f2.replace(x , mapping[x])
	f2 = f2.replace(":\n" , ": ")
	f3 = open("Assembly.asm","w")
	f3.write(f2)
	f3.close()



	# elif f1[line_ptr].startswith("do ("):



	# else:

main()