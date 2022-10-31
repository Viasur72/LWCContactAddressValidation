/**
 * Created by cnaranjo on 12/10/19.
 */
public interface IUnitOfWork {
    void registerDirty(SObject sob);
    void registerDirty(List<SObject> sobs);
    void registerNew(SObject sob);
    void registerNew(List<SObject> sobs);
    void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo);
    void registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord);
    void registerDeleted(SObject sob);
    void registerDeleted(List<SObject> sob);
    void commitWork();
    void commitWorkAndNew();


}