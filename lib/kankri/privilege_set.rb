require 'kankri/exceptions'

module Kankri
  # Wrapper around a set of privileges a client has
  class PrivilegeSet
    # Initialises a privilege set.
    #
    # @api public
    # @example Create a privilege set with no privileges.
    #   PrivilegeSet.new({})
    # @example Create a privilege set with some privileges.
    #   PrivilegeSet.new({channel_set: [:get, :put]})
    def initialize(privileges)
      @privileges = privileges
      symbolise_privileges
    end

    # Requires a certain privilege on a certain target
    # @api public
    def require(target, privilege)
      fail(InsufficientPrivilegeError) unless has?(target, privilege)
    end

    # Checks to see if a certain privilege exists on a given target
    #
    # @api public
    # @example Check your privilege.
    #   privs.has?(:channel, :put)
    #   #=> false
    #
    # @param target [Symbol] The handler target the privilege is for.
    # @param privilege [Symbol] The privilege (one of :get, :put, :post or
    #   :delete).
    #
    # @return [Boolean] true if the privileges are sufficient; false
    #   otherwise.
    def has?(privilege, target)
      PrivilegeChecker.new(target, privilege, @privileges).check?
    end

    private

    # @api private
    def symbolise_privileges
      @privileges = Hash[@privileges.map do |key, key_privs|
        [key.to_sym, symbolise_privilege_list(key_privs)]
      end]
    end

    # @api private
    def symbolise_privilege_list(privlist)
      privlist.is_a?(Array) ? privlist.map(&:to_sym) : privlist.to_sym
    end
  end

  # A method object for checking privileges.
  class PrivilegeChecker
    # @api public
    def initialize(target, requisite, privileges)
      @target = target.intern
      @requisite = requisite.intern
      @privileges = privileges
    end

    # @api public
    def check?
      has_all? || has_direct?
    end

    private

    # @api private
    # @return [Boolean] true if this privilege set has all privileges for a
    #   target.
    def has_all?
      @privileges[@target] == :all
    end

    # @api private
    # @return [Boolean] true if this privilege set explicitly has a certain
    #   privilege for a certain target.
    def has_direct?
      target_in_privileges? && requisite_in_target_privileges?
    end

    # @api private
    def target_in_privileges?
      @privileges.key?(@target)
    end

    # @api private
    def requisite_in_target_privileges?
      @privileges[@target].include?(@requisite)
    end
  end
end
