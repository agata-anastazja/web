class Plan < ActiveRecord::Base
  has_many :subscriptions, dependent: :restrict_with_exception

  validates :name, :value, presence: true

  def description
    "#{self.name} - #{value.format} / month"
  end

  def value
    Money.new(read_attribute(:value), 'GBP')
  end

  scope :visible, -> { where(visible: true) }

  before_create  :create_stripe_counterpart
  before_destroy :destroy_stripe_counterpart

  private

  def create_stripe_counterpart
    stripe_id = self.name.to_s.parameterize

    Stripe::Plan.create(
      amount: value.cents,
      name: self.name,
      id: stripe_id,
      interval: 'month',
      currency: value.currency.iso_code
    )

    self.stripe_id = stripe_id
  end

  def destroy_stripe_counterpart
    Stripe::Plan.retrieve(self.stripe_id).delete
  end
end
