# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module GTC
  module Namespace
    class Base
      # regexp to find a camel-cased module
      MODULE_DETECT_REGEX = /^(?:[A-Z][a-z0-9]+){2,}$/

      # regexp to clean a module from it's concept
      #   MyUsersController
      #   > MyUsers
      RESOURCE_CLEAN_REGEX = /^((?:[A-Z][a-z0-9]+)+?)(?:[A-Z][a-z0-9]+)?$/

      # regexp to clean a module from it's resource
      #   MyUsersController
      #   > Controller
      CONCEPT_CLEAN_REGEX = /^(?:[A-Z][a-z0-9]+)+([A-Z][a-z0-9]+)$/

      # stores the calling class as instance
      attr_reader :klass

      class << self
        # resolves a object by provided names
        #
        #   ::GTC::Namespace::Base.resolve(:user,'cell','index')
        #   > ::User::Cell::Index
        #
        # @param [Array<String, Symbol, Array>] args - array of separated namespace strings
        # @return [Object] module
        def resolve(*args)
          path(*args).constantize
        end

        # returns the full object name as string.
        #
        #   ::GTC::Namespace::Base.path(:user, 'Models',:open_tags, 'find')
        #   > "User::Model::OpenTag::Find"
        #
        # @param [Array<String, Symbol, Array>] args - array of separated namespace strings
        # @return [String] path
        def path(*args)
          args.map(&:to_s).map(&:classify).join('::')
        end

        # builds & resolves a new module by provided module names
        #
        #   ::GTC::Namespace::Base.build(:user,'cell','index')
        #   > ::User::Cell::Index
        #
        # @param [Array<String, Symbol, Array>] args - array of separated namespace strings
        # @return [Object] module
        def build(*args)
          current = ''
          path    = path(*args)
          path.split('::').each do |mod|
            if current == '' && !Object.const_defined?(mod)
              Object.const_set(mod, Module.new)
            elsif current != '' && !current.constantize.const_defined?(mod)
              current.constantize.const_set(mod, Module.new)
            end
            current = "#{current}::#{mod}"
          end

          resolve(path)
        end

        # converts a provided module to a totally new one
        #
        #   ::GTC::Namespace::Base.transform(User::Cell::Index, [:__resource, :endpoint, :__handle])
        #   > User::Endpoint::Index
        #
        #   ::GTC::Namespace::Base.transform(Admin::UsersController, [:__scope, :home_controller])
        #   > Admin::HomeController
        #
        # @param [Object] klass
        # @param [Array] packs - packs used for packing (constant symbols can be used for namespace method invocation)
        # @param [Boolean] resolve - resolve module or return path (default: true)
        # @option packs [Symbol] :__scope - uses scope
        # @option packs [Symbol] :__concept - uses concept
        # @option packs [Symbol] :__resource - uses resource
        # @option packs [Symbol] :__section - uses section
        # @option packs [Symbol] :__service - uses service
        # @option packs [Symbol] :__handle - uses handle
        # @return [Object, String] module or path
        def transform(klass, packs, resolve = true)
          s = []
          packs.each do |pack|
            case pack
            when :__scope
              s << self.scope(klass)
            when :__concept
              s << self.concept(klass)
            when :__resource
              s << self.resource(klass)
            when :__section
              s << self.section(klass)
            when :__service
              s << self.service(klass)
            when :__handle
              s << self.handle(klass)
            else
              s << pack
            end
          end

          resolve ? self.resolve(*s) : self.path(*s)
        end

        # returns all components as array
        #
        #   components(User::Endpoint::Index)
        #   > [User, User::Endpoint, User::Endpoint::Index]
        #
        # @param [Object] klass
        # @return [Array<Object>] modules
        def components(klass)
          ary = []
          modules(klass).map do |mod|
            ary << mod
            ary.join('::').constantize
          end
        end

        # returns all modules as array
        #
        #   modules(User::Endpoint::Index)
        #   > ['User', 'Endpoint', 'Index']
        #
        # @param [Object] klass
        # @return [Array<String>] modules
        def modules(klass)
          klass.to_s.split('::')
        end

        # returns all sections as array
        #
        #   sections(User::Endpoint::Index)
        #   > [:user, :endpoint, :index]
        #
        # @param [Object] klass
        # @return [Array<Symbol>] sections
        def sections(klass)
          modules(klass).map { |mod| mod.underscore.to_sym }
        end

        # returns the scope of a provided klass.
        # PLEASE NOTE: There is no scope for a class with a single module
        #
        #   scope(User::Endpoint::Index)
        #   > :user
        #
        #   scope(User::Index)
        #   > :user
        #
        #   scope(Admin::UsersController)
        #   > :admin
        #
        #   scope(HomeController)
        #   > nil
        #
        #   scope(Member)
        #   > nil
        #
        # @param [Object] klass
        # @return [Symbol, nil] scope symbol
        def scope(klass)
          modules = self.modules(klass)
          return nil if modules.length < 2
          modules[0].underscore.to_sym
        end

        # returns the concept name of a provided klass.
        # it detects the first camel-case module and returns its concept name (camelcase string, just the last one).
        #
        # it's pendant is accessible through the *.resource* method.
        #
        #   concept(User::Endpoint::Index)
        #   > nil
        #
        #   concept(User::GamesHelper)
        #   > :helper
        #
        #   concept(Home::CategoriesInitializer::Users)
        #   > :initializer
        #
        #   concept(Admin::UsersController)
        #   > :controller
        #
        #   concept(MembersHelper::UserProvider)
        #   > :helper
        #
        #   concept(Category)
        #   > nil
        #
        # @param [Object] klass
        # @param [Regexp] match_regexp
        # @return [Symbol, nil] concept symbol
        def concept(klass, match_regexp = MODULE_DETECT_REGEX)
          modules = self.modules(klass)
          res     = modules.detect { |m| m.match(match_regexp) }
          return nil unless res
          res.gsub(CONCEPT_CLEAN_REGEX, '\1').underscore.to_sym
        end

        # returns the resource name of a provided klass.
        # If there is less or equal than three modules it detects the first camel-cased module and returns its resource name (all camelcase token, except the last one - then singularize).
        # For more than three modules it'll return the
        # As last fallback it uses the first module.
        #
        #   resource(User::Endpoint::Index)
        #   > :user
        #
        #   resource(User::GamesHelper)
        #   > :game
        #
        #   resource(Home::CategoriesInitializer::Users)
        #   > :category
        #
        #   resource(Admin::UsersController)
        #   > :user
        #
        #   resource(MembersHelper)
        #   > :member
        #
        #   resource(Category)
        #   > :category
        #
        # @param [Object] klass
        # @param [Regexp] match_regexp
        # @return [Symbol] resource symbol
        def resource(klass, match_regexp = MODULE_DETECT_REGEX)
          modules = self.modules(klass)

          res = if modules.length <= 3
                  (modules.detect { |m| m.match(match_regexp) } || modules[0]).gsub(RESOURCE_CLEAN_REGEX, '\1')
                else
                  modules[-3]
                end

          res.underscore.singularize.to_sym
        end

        # returns the service name of a provided klass.
        # It checks for at least three modules and returns the penultimate module.
        #
        #   service(User::Cell::Index)
        #   > :cell
        #
        #   service(User::EndpointHandler::Index)
        #   > :endpoint_handler
        #
        #   service(Member)
        #   > nil
        #
        #   service(Admin::Home::Cell::Index)
        #   > :cell
        #
        #   service(Admin::Home::Cell::Index, 1)
        #   > :home
        #
        # @param [Object] klass
        # @return [Symbol, nil] service symbol
        def service(klass)
          modules = self.modules(klass)
          return nil if modules.length < 3
          modules[-2].underscore.to_sym
        end

        # returns the section name of a provided klass and position (default: 0)
        #
        #   section(User::Cell::Index)
        #   > :user
        #
        #   section(User::EndpointHandler::Index, 1)
        #   > :endpoint_handler
        #
        #   section(Member)
        #   > :member
        #
        #   section(Admin::Home::Cell::Index, -2)
        #   > :cell
        #
        #   section(Admin::Home::Cell::Index, 1)
        #   > :home
        #
        # @param [Object] klass
        # @param [Integer] pos - section position
        # @return [Symbol, nil] section symbol
        def section(klass, pos = 0)
          self.sections(klass)[pos]
        end

        # returns the handle name of a provided klass.
        # It checks for at least three modules and returns the last module name.
        #
        #   handle(User::Endpoint::Index)
        #   > :index
        #
        #   handle(Member)
        #   > nil
        #
        # @param [Object] klass
        # @return [Symbol] handle symbol
        def handle(klass)
          modules = self.modules(klass)
          return nil if modules.length < 3
          modules[-1].underscore.to_sym
        end

        # prints a info string for each namespace method.
        # just for debugging
        # @param [Object] klass
        def info(klass)
          puts "-----------------------------------------------------------------------------------------------"
          puts "=> #{klass} <="
          %w(components modules sections scope concept resource service handle).each do |m|
            puts "#{m.ljust(10)}: #{send(m, klass)}"
          end
          puts "-----------------------------------------------------------------------------------------------"
        end
      end

      def initialize(object)
        klass = object.is_a?(Module) ? object : object.class
        raise "Generating a namespace from a Namespace will break the universe!" if klass <= ::GTC::Namespace::Base

        @klass = klass
      end

      # returns all components as array
      # See ::GTC::Namespace::Base.components
      def components
        self.class.components(klass)
      end

      # returns all modules as array
      # See ::GTC::Namespace::Base.modules
      def modules
        self.class.modules(klass)
      end

      # returns all sections as array
      # See ::GTC::Namespace::Base.sections
      def sections
        self.class.sections(klass)
      end

      # returns the scope of a provided klass.
      # PLEASE NOTE: There is no scope for a class with a single module
      #
      # See ::GTC::Namespace::Base.scope
      def scope
        self.class.scope(klass)
      end

      # returns the concept name of a provided klass.
      # it detects the first camel-case module and returns its concept name (camelcase string, just the last one).
      #
      # See ::GTC::Namespace::Base.concept
      def concept
        self.class.concept(klass)
      end

      # returns the resource name of a provided klass.
      # It checks for at least three modules and returns the first module name.
      # If there is more or less than three modules it detects the first camel-cased module and returns its resource name (all camelcase token, except the last one - then singularize).
      # As last fallback it uses the first module.
      #
      # See ::GTC::Namespace::Base.resource
      def resource
        self.class.resource(klass)
      end

      # returns the service name of a provided klass.
      # It checks for at least three modules and returns the penultimate service.
      #
      # See ::GTC::Namespace::Base.service
      def service
        self.class.service(klass)
      end

      # returns the section name of a provided klass.
      #
      # See ::GTC::Namespace::Base.section
      def section(pos = 0)
        self.class.section(klass, pos)
      end

      # returns the handle name of a provided klass.
      # It checks for at least three modules and returns the last module name.
      #
      # See ::GTC::Namespace::Base.handle
      def handle
        self.class.handle(klass)
      end

      # converts a provided module to a totally new one
      #
      # See ::GTC::Namespace::Base.transform
      def transform(packs, resolve = true)
        self.class.transform(klass, packs, resolve)
      end

      # prints a info string for each namespace method.
      # just for debugging
      #
      # See ::GTC::Namespace::Base.info
      def info
        self.class.info(klass)
      end
    end
  end
end