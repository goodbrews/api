shared_examples 'a sluggable' do
  let(:klass) { described_class.to_s.underscore.to_sym }
  let(:sluggable) { Factory(klass) }

  it 'validates the uniqueness of the slug' do
    other = Factory.build(klass, name: sluggable.name, slug: sluggable.slug)
    expect(other).not_to be_valid
    expect(other.errors[:slug]).to include('has already been taken')
  end

  it 'generates a slug before creation' do
    expect(sluggable.slug).to be_present
  end

  it 'appends digits to create unique slugs' do
    other = Factory(klass, name: sluggable.name)
    expect(other.slug).to end_with('-2')

    one_more = Factory(klass, name: sluggable.name)
    expect(one_more.slug).to end_with('-3')
  end

  it 'overrides #to_param to return the slug' do
    expect(sluggable.to_param).to eq(sluggable.slug)
  end

  it 'defines a .from_param scope to return a model from a slug' do
    expect(sluggable.class.from_param(sluggable.slug)).to eq(sluggable)
  end
end
