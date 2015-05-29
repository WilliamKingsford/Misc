#! /usr/bin/python2.2

# Copyright (C) 2002 by Martin Pool <mbp@samba.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version
# 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Populate a tree with pseudo-randomly distributed files to test
# rsync.

from __future__ import generators
import random, string, os, os.path, sys

if len(sys.argv) != 8:
	print 'Syntax: python maketree.py <max_files> <depth> <n_children>'
	print '		<n_files> <n_symlinks> <size> <path>'
	print 'if <size> is 0, file size will be random.'
else:
	depth = int(sys.argv[2])
	n_children = int(sys.argv[3])
	n_files = int(sys.argv[4])
	n_symlinks = int(sys.argv[5])

	name_chars = string.digits + string.letters

	abuffer = 'a' * 1024

	def random_name_chars():
	    a = ""
	    for i in range(10):
	        a = a + random.choice(name_chars)
	    return a

	    
	def generate_names():
	    n = 0
	    while 1:
	        yield "%05d_%s" % (n, random_name_chars())
	        n += 1


	class TreeBuilder:
	    def __init__(self):
	        self.total_entries = long(sys.argv[1]) # long(1e8)
	        self.actual_size = 0
	        self.name_gen = generate_names()
	        self.all_files = []
	        self.all_dirs = []
	        self.all_symlinks = []


	    def random_size(self):
	        return random.lognormvariate(4, 2)


	    def random_symlink_target(self):
	        what = random.choice(['directory', 'file', 'symlink', 'none'])
	        try:
	            if what == 'directory':
	                return random.choice(self.all_dirs)
	            elif what == 'file':
	                return random.choice(self.all_files)
	            elif what == 'symlink':
	                return random.choice(self.all_symlinks)
	            elif what == 'none':
	                return self.name_gen.next()
	        except IndexError:
	            return self.name_gen.next()


	    def can_continue(self):
	        self.total_entries -= 1
	        return self.total_entries > 0

	        
	    def build_tree(self, prefix, depth):
	        """Generate a breadth-first tree"""
	        for count, function in [[n_files, self.make_file],
	                                [n_symlinks, self.make_symlink],
	                                [n_children, self.make_child_recurse]]:
	            for i in range(count):
	                if not self.can_continue():
	                    return
	                name = os.path.join(prefix, self.name_gen.next())
	                function(name, depth)


	    def print_summary(self):
	        print "total bytes: %d" % self.actual_size


	    def make_child_recurse(self, dname, depth):
	        if depth > 1:
	            self.make_dir(dname)
	            self.build_tree(dname, depth-1)


	    def make_dir(self, dname, depth='ignore'):
	        print "%s/" % (dname)
	        os.mkdir(dname)
	        self.all_dirs.append(dname)


	    def make_symlink(self, lname, depth='ignore'):
	        target = self.random_symlink_target()
	        print "%s -> %s" % (lname, target)
	        os.symlink(target, lname)
	        self.all_symlinks.append(lname)

	    def make_file(self, fname, depth='ignore'):
	        if int(sys.argv[6]) == 0:
	        	size = long(self.random_size())
	        else:
	        	size = int(sys.argv[6])
	        print "%-70s %d" % (fname, size)
	        f = open(fname, 'w')
	        f.truncate(size)
	        self.fill_file(f, size)
	        self.all_files.append(fname)
	        self.actual_size += size

	    def fill_file(self, f, size):
	        f.write(os.urandom(size))

	    
	tb = TreeBuilder()
	tb.build_tree(sys.argv[7], depth)
	tb.print_summary()
