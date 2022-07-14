# frozen_string_literal: true

module Dummy
  module Resolver
    module UserHandler
      module Cmd
        class Import

        end
      end
    end
  end

  class Base

    def hello
      "Hello #{world}"
    end

    def world
      'world!'
    end

    def not_world
      'not_world!'
    end

    def world_alias
      world
    end
  end

  class Numeric

    attr_reader :str

    def initialize(str)
      @str = str
    end

    def to_s
      str
    end
  end

  class Child < Base

    def world
      'WORLD!!!'
    end
  end

  class AnotherChild < Base

  end

  class UsersController

  end

  module Cell
    class Index

    end

    class Show

    end
  end

  module Endpoint
    class Index

    end
  end

  module Dummy
    class Index

    end
  end
end