shared_examples 'a sluggable' do
  let(:klass) { described_class.to_s.underscore.to_sym }
  let(:sluggable) { Factory(klass) }

  it 'validates the uniqueness of the slug' do
    other = Factory.build(klass, name: sluggable.name, slug: sluggable.slug)
    other.should_not be_valid
    other.errors[:slug].should include('has already been taken')
  end

  it 'generates a slug before creation' do
    sluggable.slug.should be_present
  end

  it 'appends digits to create unique slugs' do
    other = Factory(klass, name: sluggable.name)
    other.slug.should end_with('-2')

    one_more = Factory(klass, name: sluggable.name)
    one_more.slug.should end_with('-3')
  end

  it 'overrides #to_param to return the slug' do
    sluggable.to_param.should eq(sluggable.slug)
  end
end
