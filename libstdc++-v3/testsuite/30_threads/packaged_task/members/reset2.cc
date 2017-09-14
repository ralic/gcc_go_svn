// { dg-do run }
// { dg-options "-pthread"  }
// { dg-require-effective-target c++11 }
// { dg-require-effective-target pthread }
// { dg-require-cstdint "" }
// { dg-require-gthreads "" }

// Copyright (C) 2009-2017 Free Software Foundation, Inc.
//
// This file is part of the GNU ISO C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License along
// with this library; see the file COPYING3.  If not see
// <http://www.gnu.org/licenses/>.


#include <future>
#include <testsuite_hooks.h>

int iota() { static int i = 0; return i++; }

void test01()
{
  std::packaged_task<int()> p1(iota);
  std::future<int> f1 = p1.get_future();

  p1();
  p1.reset();

  VERIFY( p1.valid() );
  VERIFY( f1.get() == 0 );

  std::future<int> f2 = p1.get_future();
  p1();
  VERIFY( f2.get() == 1 );
}

int main()
{
  test01();
  return 0;
}
