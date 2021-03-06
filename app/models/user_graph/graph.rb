require 'set'

class UserGraph::Graph
  attr_reader :center, :nodes, :edges

  def initialize(center)
    @center = center
    @nodes  = Set.new []
    @edges  = Set.new []
  end

  def to_adjacency_matrix
    matrix = Array.new(@nodes.size) { Array.new(@nodes.size) }

    @nodes.each_with_index do |ni, i|
      @nodes.each_with_index do |nj, j|
        if @edges.include?([ni.id, nj.id, 1]) || @edges.include?([ni.id, nj.id, 2])
          matrix[i][j] = 1
        else
          matrix[i][j] = 0
        end
      end
    end

    matrix
  end

  def empty?
    @nodes.size == 0
  end

  def to_json
    {
      center: @center.nil? ? nil : "n#{@center.id}",
      nodes: build_nodes_json,
      edges: build_edges_json
    }.to_json
  end

  def to_gdf(_options = {})
    str = "nodedef> name VARCHAR, label VARCHAR, plan_type VARCHAR, size INT, twitter_url VARCHAR, facebook_url VARCHAR\n"
    @nodes.each { |n| str << "#{n.id}, #{n.name}, #{plan_type(n)}, #{plan_to_size(n)}, #{n.twitter.try(:profile_url)}, #{n.facebook.try(:profile_url)}\n"}
    str << "edgedef> user VARCHAR, friend VARCHAR\n"
    @edges.each { |e| str << "#{e[0]}, #{e[1]}\n"}
    str
  end

  private

  def build_nodes_json
    @nodes.to_a.sort { |x, y| x.showcase && !y.showcase ? 1 : (y.showcase ? -1 : 0) }.map do |x|
      {
        id: "n#{x.id}",
        label: (x.showcase || x.id == @center.try(:id)) ? "#{x.name}" : "",
        value: @edges.select { |e| e[0..1].include?(x.id) }.size,
        group: x.community,
        meta: {
          name: x.name,
          text: x.showcase_text,
          url: x.url,
          plan: plan_type(x),
          showcase: x.showcase
        }
      }
    end
  end

  def build_edges_json
    edges = Set.new []
    @edges.each { |e| (edges << e) unless (edges.include?(e) || edges.include?([e[1], e[0], e[2]])) }
    edges.map.with_index { |x, i| { id: "e#{i}", from: "n#{x[0]}", to: "n#{x[1]}", value: x[2] } }
  end

  def plan_to_size(user)
    return 10 if (user.subscription.nil? || !user.subscription.active? || user.subscription.plan.nil?)
    user.subscription.plan.value + 100
  end

  def plan_type(user)
    return :inactive if user.subscription.nil? || !user.subscription.active?
    user.subscription.plan.name
  end

  def title(user)
    lines = []
    lines << [user.name, user.showcase_text.blank? ? nil : user.showcase_text].compact.join(", ")
    lines << user.url
    lines.join("<br />")
  end
end
