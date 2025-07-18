# frozen_string_literal: true

# Abstract base service for all domain logic.
#
# Subclasses must implement business operations.
class BaseService
  def get(_id)
    raise NotImplementedError, "Subclasses must implement get"
  end
end
