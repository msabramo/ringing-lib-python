cdef class RowBlock:

    cdef row_block *thisptr

    cdef vector[change] change_vector

    cdef change_list

    def __cinit__(self, changes, starting_row=None):
        cdef row starting_row_obj = deref(Row(starting_row).thisptr)

        self.change_list = []
        for ch in changes:
            self.change_vector.push_back(deref((<Change?>ch).thisptr))
            self.change_list.append(ch)

        if starting_row is None:
            self.thisptr = new row_block(self.change_vector)
        else:
            self.thisptr = new row_block(self.change_vector, starting_row_obj)

    def __dealloc__(self):
        del self.thisptr

    property size:
        def __get__(self):
            return self.thisptr.size()

    property changes:
        def __get__(self):
            return self.change_list

    def set_start(self, starting_row):
        cdef Row starting_row_obj = Row(starting_row)
        self.thisptr.set_start(deref(starting_row_obj.thisptr))
        return starting_row_obj

    def recalculate(self, int start=0):
        if 0 <= start < self.size:
            self.thisptr.recalculate(start)
            return self
        else:
            raise IndexError

    def __repr__(self):
        cdef str changes = ', '.join([repr(ch) for ch in self.change_list])
        if self[0].is_rounds():
            return 'RowBlock([{changes}])'.format(changes=changes)
        else:
            return 'RowBlock([{changes}], {row})'.format(
                changes=changes,
                row=repr(self[0]),
            )

    def __len__(self):
        return self.size

    def __getitem__(self, int x):
        cdef Row result = Row()

        if 0 <= x < self.size:
            result.thisptr[0] = deref(self.thisptr)[x]
            return result
        else:
            raise IndexError

    def __setitem__(self, int x, y):
        cdef Row ry = Row(y)

        if 0 <= x < self.size:
            deref(self.thisptr)[x] = deref(ry.thisptr)
        else:
            raise IndexError