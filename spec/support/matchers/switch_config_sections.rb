#
# Copyright (c) 2016, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   Neither the name of Arista Networks nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

def get_child(section, line)
  section.children.each do |child|
    return child if child.line == line
  end
  nil
end

def section_compare(section1, section2)
  # Verify lines are the same
  return false unless section1.line == section2.line

  # Verify cmds are the same
  c1 = Set.new(section1.cmds)
  c2 = Set.new(section2.cmds)
  return false unless c1 == c2

  # Return false if the number of children are different
  return false unless section1.children.length == section2.children.length

  # Using a depth first search to recursively descend through the
  # children doing a comparison.
  section1.children.each do |s1_child|
    s2_child = get_child(section2, s1_child.line)
    return false unless s2_child
    return false unless section_compare(s1_child, s2_child)
  end
  true
end

RSpec::Matchers.define :section_equal do |expected|
  if expected.class != Rbeapi::SwitchConfig::Section
    raise 'expected is not a Rbeapi::SwitchConfig::Section class'
  end

  match do |actual|
    if actual.class != Rbeapi::SwitchConfig::Section
      raise 'actual is not a Rbeapi::SwitchConfig::Section class'
    end

    section_compare(actual, expected)
  end

  description do
    'Verifies contents of section with a deep class comparison.'
  end

  diffable
end
