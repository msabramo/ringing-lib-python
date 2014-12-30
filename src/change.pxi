cdef class Change:

    cdef change *thisptr

    def __cinit__(self, input=None, change_str=None):
        if input is None:
            self.thisptr = new change()
        elif isinstance(input, Change):
            self.thisptr = new change(deref((<Change>input).thisptr))
        elif isinstance(input, int):
            if 0 <= input <= 256:
                if change_str is None:
                    self.thisptr = new change(<int>input)
                elif isinstance(change_str, unicode):
                    self.thisptr = new change(<int>input,
                                              <string>(change_str.encode()))
                elif isinstance(change_str, bytes):
                    self.thisptr = new change(<int>input, <string>change_str)
                else:
                    raise TypeError('supplied change must be a string')
            else:
                raise ValueError('number of bells must be between 0 and 256')
        else:
            raise TypeError

    def __dealloc__(self):
        del self.thisptr

    def reverse(self):
        cdef Change result = Change()
        result.thisptr[0] = self.thisptr.reverse()
        return result

    property bells:
        def __get__(self):
            return self.thisptr.bells()

    def sign(self):
        return self.thisptr.sign()

    def find_swap(self, int i):
        if 0 <= i < (self.thisptr.bells() - 1):
            return self.thisptr.findswap(bell(i))
        else:
            raise IndexError('bell number out of range')

    def find_place(self, int i):
        if 0 <= i <= (self.thisptr.bells() - 1):
            return self.thisptr.findplace(bell(i))
        else:
            raise IndexError('bell number out of range')

    def swap_pair(self, int i):
        return self.thisptr.swappair(bell(i))

    def internal(self):
        return self.thisptr.internal()

    def count_places(self):
        return self.thisptr.count_places()

    def __richcmp__(x, y, int op):
        cdef change cx
        cdef change cy

        if isinstance(x, Change):
            cx = deref(Change(x).thisptr)
        elif isinstance(x, bytes) or isinstance(x, unicode):
            cx = deref(Change(y.bells, x).thisptr)
        else:
            return NotImplemented

        if isinstance(y, Change):
            cy = deref(Change(y).thisptr)
        elif isinstance(y, bytes) or isinstance(y, unicode):
            cy = deref(Change(x.bells, y).thisptr)
        else:
            return NotImplemented

        if op == 0:  # <
            return cx < cy
        elif op == 1:  # <=
            return cx <= cy
        elif op == 2:  # ==
            return cx == cy
        elif op == 3:  # !=
            return cx != cy
        elif op == 4:  # >
            return cx > cy
        elif op == 5:  # >=
            return cx >= cy

    def __str__(self):
        if PY_MAJOR_VERSION < 3:
            return self.__bytes__()
        else:
            return self.__unicode__()

    def __bytes__(self):
        return self.thisptr.print()

    def __unicode__(self):
        return self.thisptr.print().decode()

    def __repr__(self):
        if self.thisptr.bells():
            return 'Change({bells}, "{change}")'.format(
                bells = self.thisptr.bells(),
                change = self.__str__(),
            )
        else:
            return 'Change()'
