# -*- coding: utf-8 -*-
module FU
    class DB
        module Property

            const_def :BASE, File.dirname(__FILE__)

            autoload :RefCode,    BASE + '/property/ref_code'
            autoload :Email,      BASE + '/property/email'
            autoload :StringEnum, BASE + '/property/string_enum'
            autoload :StringSet,  BASE + '/property/string_set'

            const_def :NAMEREGEX, /[[:print:]]/
        end
    end
end

# To make it easy to refer to from within random class definitions.
::DataMapper::Property::StringEnum = ::FU::DB::Property::StringEnum
::DataMapper::Property::StringSet  = ::FU::DB::Property::StringSet

::DataMapper::Property::RefCode    = ::FU::DB::Property::RefCode
::DataMapper::Property::Email      = ::FU::DB::Property::Email
