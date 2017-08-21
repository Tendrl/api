module NodePresenter
  class << self
    def list(nodes_list)
      nodes = []
      nodes_list.each do |node|
        node.each do |_, attributes|
          attributes.slice!('nodecontext')
          node_attr = attributes.delete('nodecontext')
          node_attr.delete('tags')
          next if node_attr.blank?
          nodes << node_attr.merge(attributes)
        end
      end
      nodes
    end
  end
end
