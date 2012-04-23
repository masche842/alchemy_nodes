Alchemy::Element.class_eval do

  # All Elements inside a cell are a list. All Elements not in cell are in the cell_id.nil list.
  acts_as_list :scope => [:page_id, :cell_id, :container_id]

  validate :extend_position_validation_scope

  def extend_position_validation_scope
    if self.errors[:position] and self.container_id and
      self.class.where(:position => self.position, :cell_id => self.cell_id, :container_id => self.container_id).where("id != ?", self.id).first.nil?
      self.errors.delete(:position)
      true
    end
  end

  belongs_to :container, :class_name => AlchemyNodes::Container

  has_and_belongs_to_many :to_be_sweeped_elements_for_containers, :class_name => 'AlchemyNodes::Container', :uniq => true, :join_table => 'alchemy_elements_containers'

  # TODO: add a trashed column to elements table
  scope :trashed, where(:page_id => nil, :container_id => nil).order('updated_at DESC')
  scope :not_trashed, where('`alchemy_elements`.`page_id` IS NOT NULL OR `alchemy_elements`.`container_id` IS NOT NULL')
  scope :all_siblings, lambda { |element| element.page ? where(:page => self.page) : where(:container_id => self.container_id) }


  def self.new_from_scratch(attributes)
    attributes.stringify_keys!
    return Alchemy::Element.new if attributes['name'].blank?
    element_descriptions = Alchemy::Element.descriptions
    return if element_descriptions.blank?
    element_scratch = element_descriptions.select { |m| m["name"] == attributes['name'].split('#').first }.first
    element = Alchemy::Element.new(
      element_scratch.except('contents', 'available_contents', 'display_name').merge({:page_id => attributes['page_id']})
    )
    element.container_id = attributes[:container_id]
    element
  end

  # List all elements for page_layout
  def self.all_for_page(page)
    #raise TypeError if page.class.name != "Alchemy::Page"
    # if page_layout has cells, collect elements from cells and group them by cellname
    page_layout = Alchemy::PageLayout.get(page.page_layout)
    if page_layout.blank?
      logger.warn "\n++++++\nWARNING! Could not find page_layout description for page: #{page.name}\n++++++++\n"
      return []
    end
    elements_for_layout = []
    elements_for_layout += all_definitions_for(page_layout['elements'])
    return [] if elements_for_layout.blank?
    # all unique elements from this layout
    unique_elements = elements_for_layout.select { |m| m["unique"] == true }
    elements_already_on_the_page = page.elements
    # delete all elements from the elements that could be placed that are unique and already and the page
    unique_elements.each do |unique_element|
      elements_already_on_the_page.each do |already_placed_element|
        if already_placed_element.name == unique_element["name"]
          elements_for_layout.delete(unique_element)
        end
      end
    end
    return elements_for_layout
  end

  # Returns next Element on self.page or nil. Pass a Element.name to get next of this kind.
  def next(name = nil)
    elements = self.class.all_siblings(self)
    elements = elements.where(:name => name) if name
    elements.where("position > ?", self.position).order("position ASC").limit(1)
  end

  # Returns previous Element on self.page or nil. Pass a Element.name to get previous of this kind.
  def prev(name = nil)
    elements = self.class.all_siblings(self)
    elements = elements.where(:name => name) if name
    elements.where("position < ?", self.position).order("position ASC").limit(1)
  end

  # Stores the page into `to_be_sweeped_pages` (Pages that have to be sweeped after updating element).
  def store_page(page)
    return true if page.nil?
    if page.is_a? Alchemy::Page
      unless self.to_be_sweeped_pages.include? page
        self.to_be_sweeped_pages << page
        self.save
      end
    else
      store_container(page)
    end
  end

  # Stores the container into `to_be_sweeped_elements_for_containers` (Pages that have to be sweeped after updating element).
  def store_container(container)
    return true if container.nil?
    unless self.to_be_sweeped_elements_for_containers.include? container
      self.to_be_sweeped_elements_for_containers << container
      self.save
    end
  end

  # Nullifies the page_id and cell_id, fold the element, set it to unpublic and removes its position.
  def trash
    self.attributes = {
      :page_id => nil,
      :container_id => nil,
      :cell_id => nil,
      :folded => true,
      :public => false
    }
    self.remove_from_list
  end

  def trashed?
    page_id.nil? and container_id.nil?
  end

  # creates the contents for this element as described in the elements.yml
  # same as in origin, but public
  def create_contents
    contents = []
    if description["contents"].blank?
      logger.warn "\n++++++\nWARNING! Could not find any content descriptions for element: #{self.name}\n++++++++\n"
    else
      description["contents"].each do |content_hash|
        contents << Alchemy::Content.create_from_scratch(self, content_hash.symbolize_keys)
      end
    end
  end
end

