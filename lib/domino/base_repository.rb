# frozen_string_literal: true

# Abstract base repository for all models.
#
# Subclasses must implement standard CRUD methods.
class BaseRepository
  def find_by_id(_id)
    raise NotImplementedError, "Subclasses must implement find_by_id"
  end

  def all
    raise NotImplementedError, "Subclasses must implement all"
  end

  def create(_attrs)
    raise NotImplementedError, "Subclasses must implement create"
  end

  def update(_id, _attrs)
    raise NotImplementedError, "Subclasses must implement update"
  end

  def delete(_id)
    raise NotImplementedError, "Subclasses must implement delete"
  end
end
