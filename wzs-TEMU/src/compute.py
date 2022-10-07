# 判别表达式格式是否正确
import re
from RegList import RegList
from Memory import Memory

def check_parentheses(self):
    all1 = []
    for i in self:
        if i == '(':
            all1.append('(')
        elif i == ')':
            if all1 and all1[-1] == '(':
                all1.pop()
            else:
                return False
    if all1:
        return False
    else:
        return True


# 提供字符串的进制转换
def to_ten(string):
    if string[1] in 'xX':
        ans = int(string, 16)
        return ans
    elif string[1] in 'oO':
        ans = int(string, 8)
        return ans
    elif string[1] in 'bB':
        ans = int(string, 2)
        return ans


# 进行预处理，分解所有的数字和符号,并且消除非十进制及寄存器
def prepear(cpus, self):
    num = ''
    final = []
    # 除去非十进制

    for i, j in enumerate(self):
        if j.isdigit():
            num += j
        else:
            if num:  # 数字的处理
                final.append(num)
                num = ''
            elif j == '-':  # 负数的处理
                if (i == 0) or (self[i - 1] in '+-*/(=@&|'):
                    num += j
                    continue
            final.append(j)
    if num:
        final.append(num)
    # print(final)
    return final


def deal(cpus, self):
    # 消除16进制
    while re.search('0[b,o,x,B,O,X][0-9,a-f,A-F]+', self) is not None:
        is_0x = re.search('0[b,o,x,B,O,X][0-9,a-f,A-F]+', self)
        temp_0x = to_ten(is_0x.group())
        self = re.sub('0[b,o,x,B,O,X][0-9,a-f,A-F]+', str(temp_0x), self, 1)
        # 消除寄存器
    while (re.search('(\$[0-9,a-z,A-Z]+)', self) != None):
        is_0x = re.search('(\$[0-9,a-z,A-Z]+)', self)
        temp_0x = (is_0x.group())
        temp_string = ""
        for i in range(0, 33):
            if RegList(i).name == temp_0x[1:len(temp_0x)]:
                temp_string = f"{cpus[i].low32:08x}"
                temp_string = to_ten("0x" + str(temp_string))
                break
            if i == 32:
                print("Register name may be wrong")
                return "0"
        self = re.sub('(\$[0-9,a-z,A-Z]+)', str(temp_string), self, 1)
    # 去除单目运算符!
    while ('!' in self):
        local = self.find('!')
        if self[local + 1] == "=":
            self = self[0:local] + '@' + self[local + 2:len(self)]
        elif self[local + 1] != '(':
            is_0x = re.search('![\d]+', self)
            temp_0x = (is_0x.group())
            if temp_0x[1] == '0':
                temp_0x = '1'
            else:
                temp_0x = '0'
            self = re.sub('![\d]+', temp_0x, self, 1)
        else:
            i = local + 2
            left = 1
            right = 0
            while left != right:
                if self[i] == '(':
                    left += 1
                if self[i] == ')':
                    right += 1
                i += 1
            if deal(cpus, self[local + 1:i]) != "0":
                temp_ans = "0"
            else:
                temp_ans = "1"
            self = self[0:local] + (temp_ans) + self[i:len(self)]
            # print(self)
    # 去除单目运算符*
    #print(self)
    while (re.search('(?<![0-9,\)])\*', self) != None):
        is_0x = re.search('(?<![0-9,\)])\*', self)
        local = (is_0x.start())
        #print(local)
        if self[local + 1] != '(':
            # 寻找后面的数字
            is_0x = re.search('(?<![0-9,\)])\*[\d]+', self)
            temp_0x = (is_0x.group())
            temp_0x = temp_0x[1:len(temp_0x)]  # 根据这个地址取数
            temp = str(cpus.read_m(int(temp_0x)))
            self = re.sub('(?<![0-9,\)])\*[\d]+', temp, self, 1)
        else:
            i = local + 2
            left = 1
            right = 0
            while left != right:
                if self[i] == '(':
                    left += 1
                if self[i] == ')':
                    right += 1
                i += 1
            temp_1x = deal(cpus, self[local + 1:i])  # 根据这个地址取数
            temp = str(cpus.read_m(int(temp_1x)))
            self = self[0:local] + temp + self[i:len(self)]
        #print(self)
    self = re.sub('==', '=', self)
    self = re.sub('&&', '&', self)
    self = re.sub('\|\|', '|', self)
    lst = prepear(cpus, self)
    ans = deal_expression(lst)
    return ans


def find(lst, oper):
    loc = len(lst) - 1
    while (loc > 0):
        if lst[loc] in oper:
            return loc
        loc -= 1
    return -1


def find_op(lst):
    loc = -1
    oper = ['&', '|']
    loc = find(lst, oper)
    if loc != (-1):
        return loc
    oper = ['=', '@']
    loc = find(lst, oper)
    if loc != (-1):
        return loc
    oper = ['+', '-']
    loc = find(lst, oper)
    if loc != (-1):
        return loc
    oper = ['*', '/']
    loc = find(lst, oper)
    if loc != (-1):
        return loc
    print("Error")


# 进行四则运算的函数
def deal_expression(lst):
    # 成对拆括号
    left = right = i = 0
    while '(' in lst:
        while lst[i] != ')':
            i += 1
        j = i
        while lst[i] != '(':
            i -= 1
        lst = lst[0:i] + [deal_expression(lst[i + 1:j])] + lst[j + 1:len(lst)]
        # print(lst)
    # 根据优先级进行计算
    if len(lst) == 1 or len(lst) == 0:
        # print("single",lst[0])
        return int(lst[0])
    op = find_op(lst)
    val1 = val2 = 0
    val1 = (deal_expression(lst[0:op]))
    val2 = (deal_expression(lst[op + 1:len(lst)]))
    # print(val1,lst[op],val2)
    if lst[op] == '+':
        return val1 + val2
    elif lst[op] == '-':
        return val1 - val2
    elif lst[op] == '*':
        return val1 * val2
    elif lst[op] == '/':
        return val1 // val2
    if lst[op] == '|':
        if val1 == 0 and val2 == 0:
            return "0"
        else:
            return "1"
    elif lst[op] == '&':
        if val1 != 0 and val2 != 0:
            return "1"
        else:
            return "0"
    elif lst[op] == '=':
        if val1 == val2:
            return "1"
        else :
            return "0"
    elif lst[op] == '@':
        if val1!=val2:
            return "1"
        else:
            return "0"
