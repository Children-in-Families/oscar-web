# This is an autogenerated file for dynamic methods in ClientEnrollment
# Please rerun rake rails_rbi:models to regenerate.
# typed: strong

class ClientEnrollment::ActiveRecord_Relation < ActiveRecord::Relation
  include ClientEnrollment::ModelRelationShared
  extend T::Generic
  Elem = type_member(fixed: ClientEnrollment)
end

class ClientEnrollment::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include ClientEnrollment::ModelRelationShared
  extend T::Generic
  Elem = type_member(fixed: ClientEnrollment)
end

class ClientEnrollment < ActiveRecord::Base
  extend T::Sig
  extend T::Generic
  extend ClientEnrollment::ModelRelationShared
  include ClientEnrollment::InstanceMethods
  Elem = type_template(fixed: ClientEnrollment)
end

module ClientEnrollment::InstanceMethods
  extend T::Sig

  sig { returns(T.nilable(Integer)) }
  def client_id(); end

  sig { params(value: T.nilable(Integer)).void }
  def client_id=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def client_id?(*args); end

  sig { returns(T.untyped) }
  def created_at(); end

  sig { params(value: T.untyped).void }
  def created_at=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def created_at?(*args); end

  sig { returns(T.nilable(T.untyped)) }
  def deleted_at(); end

  sig { params(value: T.nilable(T.untyped)).void }
  def deleted_at=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def deleted_at?(*args); end

  sig { returns(T.nilable(Date)) }
  def enrollment_date(); end

  sig { params(value: T.nilable(Date)).void }
  def enrollment_date=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def enrollment_date?(*args); end

  sig { returns(Integer) }
  def id(); end

  sig { params(value: Integer).void }
  def id=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def id?(*args); end

  sig { returns(T.nilable(Integer)) }
  def program_stream_id(); end

  sig { params(value: T.nilable(Integer)).void }
  def program_stream_id=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def program_stream_id?(*args); end

  sig { returns(T.nilable(T.untyped)) }
  def properties(); end

  sig { params(value: T.nilable(T.untyped)).void }
  def properties=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def properties?(*args); end

  sig { returns(T.nilable(String)) }
  def status(); end

  sig { params(value: T.nilable(String)).void }
  def status=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def status?(*args); end

  sig { returns(T.untyped) }
  def updated_at(); end

  sig { params(value: T.untyped).void }
  def updated_at=(value); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def updated_at?(*args); end

end

class ClientEnrollment
  extend T::Sig

  sig { returns(T.nilable(::Client)) }
  def client(); end

  sig { params(value: T.nilable(::Client)).void }
  def client=(value); end

  sig { returns(::ClientEnrollmentTracking::ActiveRecord_Associations_CollectionProxy) }
  def client_enrollment_trackings(); end

  sig { params(value: T.any(T::Array[::ClientEnrollmentTracking], ::ClientEnrollmentTracking::ActiveRecord_Associations_CollectionProxy)).void }
  def client_enrollment_trackings=(value); end

  sig { returns(::FormBuilderAttachment::ActiveRecord_Associations_CollectionProxy) }
  def form_builder_attachments(); end

  sig { params(value: T.any(T::Array[::FormBuilderAttachment], ::FormBuilderAttachment::ActiveRecord_Associations_CollectionProxy)).void }
  def form_builder_attachments=(value); end

  sig { returns(T.nilable(::LeaveProgram)) }
  def leave_program(); end

  sig { params(value: T.nilable(::LeaveProgram)).void }
  def leave_program=(value); end

  sig { returns(T.nilable(::ProgramStream)) }
  def program_stream(); end

  sig { params(value: T.nilable(::ProgramStream)).void }
  def program_stream=(value); end

  sig { returns(::Tracking::ActiveRecord_Associations_CollectionProxy) }
  def trackings(); end

  sig { params(value: T.any(T::Array[::Tracking], ::Tracking::ActiveRecord_Associations_CollectionProxy)).void }
  def trackings=(value); end

  sig { returns(::PaperTrail::Version::ActiveRecord_Associations_CollectionProxy) }
  def versions(); end

  sig { params(value: T.any(T::Array[::PaperTrail::Version], ::PaperTrail::Version::ActiveRecord_Associations_CollectionProxy)).void }
  def versions=(value); end

end

module ClientEnrollment::ModelRelationShared
  extend T::Sig

  sig { returns(ClientEnrollment::ActiveRecord_Relation) }
  def all(); end

  sig { params(block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def active(*args); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def deleted_after_time(*args); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def deleted_before_time(*args); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def deleted_inside_time_window(*args); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def enrollments_by(*args); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def find_by_program_stream_id(*args); end

  sig { params(args: T.untyped).returns(ClientEnrollment::ActiveRecord_Relation) }
  def inactive(*args); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def select(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def order(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def reorder(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def group(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def limit(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def offset(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def joins(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def where(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def rewhere(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def preload(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def eager_load(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def includes(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def from(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def lock(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def readonly(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def or(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def having(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def create_with(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def distinct(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def references(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def none(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def unscope(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(ClientEnrollment::ActiveRecord_Relation) }
  def except(*args, &block); end

end
