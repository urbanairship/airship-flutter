const TAG_OPERATION_ADD = "add";
const TAG_OPERATION_REMOVE = "remove";
const TAG_OPERATION_SET = "set";

class TagGroupOperation {
  static const TAG_OPERATION_GROUP_NAME = "group";
  static const TAG_OPERATION_TYPE = "operationType";
  static const TAG_OPERATION_TAGS = "tags";

  final String group;
  final String operationType;
  final List<String> tags;

  TagGroupOperation(String group, List<String> tags, String operationType)
      : this.group = group,
        this.tags = tags,
        this.operationType = operationType;

  Map<String, dynamic> toMap() {
    return {
      TAG_OPERATION_GROUP_NAME:group,
      TAG_OPERATION_TYPE:operationType,
      TAG_OPERATION_TAGS:tags
    };
  }
}

class AddTagGroupOperation extends TagGroupOperation {
  AddTagGroupOperation(String group, List<String> tags)
      : super(group, tags, TAG_OPERATION_ADD);
}

class RemoveTagGroupOperation extends TagGroupOperation {
  RemoveTagGroupOperation(String group, List<String> tags)
      : super(group, tags, TAG_OPERATION_REMOVE);
}

class SetTagGroupOperation extends TagGroupOperation {
  SetTagGroupOperation(String group, List<String> tags)
      : super(group, tags, TAG_OPERATION_SET);

}