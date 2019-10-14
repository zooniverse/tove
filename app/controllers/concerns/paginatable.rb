module Paginatable
  extend ActiveSupport::Concern

  def paginate(scope)
    scope.page(page).per page_size
  end
end
