CREATE VIEW ELoadMenager.TagList
AS
  select t.id [tag_id],
  			 t.name [tag_name],
         t.isDel,
         count(distinct o.object_id) [cnt]
  from ELoadMenager.tags t
  left join eloadmenager.tags_to_objects o on t.id=o.tag_id
  group by t.id, t.name, t.isDel