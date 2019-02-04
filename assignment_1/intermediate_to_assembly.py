f1 = open("Intermediate.txt").read().splitlines()
f2 = open("Assembly","w")

temp_regs = { "t0":"A","t1":"B","t2":"C","t3":"D","t4":"E","t5":"F","t6":"G","t7":"H"}

line_ptr = 0

condition = 0

label_num = 0

def gen_out(com):
	f2.write(com+"\n")

def handle_conditions():
	while f1[line_ptr].startswith("t0)"):
		line_ptr+=1	


def handle_if():
	line_ptr+=1
	handle_conditions()



def handle_statement():
	global line_ptr
	if "<-" in f1[line_ptr]:
		if(f1[line_ptr].split()[0].startswith("_")):
			if(f1[line_ptr].split()[2] == "t0"):
				gen_out("STA "+f1[line_ptr].split()[0])
			else:
				gen_out("PUSH A\nMOV A " + temp_regs[f1[line_ptr].split()[2]] + "\nSTA "+ f1[line_ptr].split()[0] +"\nPOP A")
		else:
			gen_out("MOV " + temp_regs[f1[line_ptr].split()[0]] + " " + temp_regs[f1[line_ptr].split()[2]])

	elif "+=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			gen_out("ADD " + temp_regs[f1[line_ptr].split()[2]])
		else:
			gen_out("PUSH A\nMOV A "+temp_regs[f1[line_ptr].split()[0]] + "\nADD " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP A")
	
	elif "*=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			gen_out("MUL " + temp_regs[f1[line_ptr].split()[2]])
		else:
			gen_out("PUSH A\nMOV A "+temp_regs[f1[line_ptr].split()[0]] + "\nMUL " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP A")
	
	elif "\=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			gen_out("DIV " + temp_regs[f1[line_ptr].split()[2]])
		else:
			gen_out("PUSH A\nMOV A "+temp_regs[f1[line_ptr].split()[0]] + "\nDIV " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP A")

	elif "-=" in f1[line_ptr]:
		if f1[line_ptr].split()[0] == "t0":
			gen_out("SUB " + temp_regs[f1[line_ptr].split()[2]])
		else:
			gen_out("PUSH A\nMOV A "+temp_regs[f1[line_ptr].split()[0]] + "\nSUB " + temp_regs[f1[line_ptr].split()[2]] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +", A\nPOP A")

	elif "=" in f1[line_ptr]:
		if not (f1[line_ptr].split()[2].startswith("_")):
			gen_out("MVI A "+ f1[line_ptr].split()[2])
		else:
			if(f1[line_ptr].split()[0] == "t0"):
				gen_out("LDA "+f1[line_ptr].split()[2])
			else:
				gen_out("PUSH A\nLDA " + f1[line_ptr].split()[2] + "\nMOV "+ temp_regs[f1[line_ptr].split()[0]] +" A\nPOP A")
	else:
		print("Finished")
	line_ptr+=1

def read_next_line():
	gen_out("ORG 0000h")
	global line_ptr
	while(1):
		handle_statement()
		if line_ptr==len(f1):
			break
	gen_out("END")
	f2.close()
	# if f1[line_ptr].startswith("if ("):

	# elif f1[line_ptr].startswith("while ("):

	# elif f1[line_ptr].startswith("then {"):

	# elif f1[line_ptr].startswith("do ("):

	# elif f1[line_ptr].startswith("BEGIN{"):

	# elif f1[line_ptr].startswith("} END"):

	# elif f1[line_ptr].startswith("}"):

	# else:

read_next_line()