#
# Copyright (c) 2014, Arista Networks, Inc.
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

##
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Utils module
  module Utils
    ##
    # Iterates through a hash structure and converts all of the keys
    # to symbols.
    #
    # @param [Hash] :value The hash structure to convert the keys
    #
    # @return [Hash] An updated hash structure with all keys converted to
    #   symboles
    def self.transform_keys_to_symbols(value)
      return value unless value.is_a?(Hash)
      hash = value.each_with_object({}) do |hsh, (k, v)|
        hsh[k.to_sym] = transform_keys_to_symbols(v)
        hsh
      end
      hash
    end

    ##
    # Returns a class object from a string capable of being instatiated
    #
    # @param [String] :name The name of the class to return a constant for
    #
    # @return [Object] Returns a a class object that can be instatiated
    def self.class_from_string(name)
      name.split('::').inject(Object) do |mod, cls|
        mod.const_get(cls)
      end
    end
  end
end
