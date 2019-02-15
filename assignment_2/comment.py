import re
import sys

pat = r'(/\*.*?\*/|//.*?$)'


txt = sys.stdin.read()
# re.sub() for Testcase #4: others will just work with comment
print "\n".join(re.sub('\n\s+', '\n', comment) for comment in re.findall(pat, txt, re.DOTALL|re.MULTILINE))
