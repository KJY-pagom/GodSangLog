// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyLogCollection on Isar {
  IsarCollection<DailyLog> get dailyLogs => this.collection();
}

const DailyLogSchema = CollectionSchema(
  name: r'DailyLog',
  id: -3995615497450705259,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.dateTime),
    r'goalCalories': PropertySchema(
      id: 1,
      name: r'goalCalories',
      type: IsarType.double,
    ),
  },
  estimateSize: _dailyLogEstimateSize,
  serialize: _dailyLogSerialize,
  deserialize: _dailyLogDeserialize,
  deserializeProp: _dailyLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {
    r'meals': LinkSchema(
      id: 9048061380789538419,
      name: r'meals',
      target: r'Meal',
      single: false,
    ),
    r'exercises': LinkSchema(
      id: 4740472621702755814,
      name: r'exercises',
      target: r'Exercise',
      single: false,
    ),
    r'clips': LinkSchema(
      id: 1738175924233300260,
      name: r'clips',
      target: r'VideoClip',
      single: false,
    ),
  },
  embeddedSchemas: {},
  getId: _dailyLogGetId,
  getLinks: _dailyLogGetLinks,
  attach: _dailyLogAttach,
  version: '3.1.0+1',
);

int _dailyLogEstimateSize(
  DailyLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyLogSerialize(
  DailyLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDouble(offsets[1], object.goalCalories);
}

DailyLog _dailyLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyLog();
  object.date = reader.readDateTime(offsets[0]);
  object.goalCalories = reader.readDouble(offsets[1]);
  object.id = id;
  return object;
}

P _dailyLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyLogGetId(DailyLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyLogGetLinks(DailyLog object) {
  return [object.meals, object.exercises, object.clips];
}

void _dailyLogAttach(IsarCollection<dynamic> col, Id id, DailyLog object) {
  object.id = id;
  object.meals.attach(col, col.isar.collection<Meal>(), r'meals', id);
  object.exercises.attach(
    col,
    col.isar.collection<Exercise>(),
    r'exercises',
    id,
  );
  object.clips.attach(col, col.isar.collection<VideoClip>(), r'clips', id);
}

extension DailyLogByIndex on IsarCollection<DailyLog> {
  Future<DailyLog?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  DailyLog? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyLog?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyLog?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyLog object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyLog object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyLog> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyLog> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyLogQueryWhereSort on QueryBuilder<DailyLog, DailyLog, QWhere> {
  QueryBuilder<DailyLog, DailyLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension DailyLogQueryWhere on QueryBuilder<DailyLog, DailyLog, QWhereClause> {
  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'date', value: [date]),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateNotEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [date],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [],
          upper: [date],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [lowerDate],
          includeLower: includeLower,
          upper: [upperDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyLogQueryFilter
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {
  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> goalCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'goalCalories',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  goalCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalCalories',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> goalCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalCalories',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> goalCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalCalories',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyLogQueryObject
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {}

extension DailyLogQueryLinks
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {
  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> meals(
    FilterQuery<Meal> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'meals');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'meals', length, true, length, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'meals', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'meals', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'meals', 0, true, length, include);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  mealsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'meals', length, include, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> mealsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'meals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> exercises(
    FilterQuery<Exercise> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercises');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  exercisesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercises', length, true, length, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> exercisesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercises', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  exercisesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercises', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  exercisesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercises', 0, true, length, include);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  exercisesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercises', length, include, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  exercisesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'exercises',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> clips(
    FilterQuery<VideoClip> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'clips');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> clipsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'clips', length, true, length, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> clipsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'clips', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> clipsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'clips', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> clipsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'clips', 0, true, length, include);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
  clipsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'clips', length, include, 999999, true);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> clipsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'clips',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension DailyLogQuerySortBy on QueryBuilder<DailyLog, DailyLog, QSortBy> {
  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByGoalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCalories', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByGoalCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCalories', Sort.desc);
    });
  }
}

extension DailyLogQuerySortThenBy
    on QueryBuilder<DailyLog, DailyLog, QSortThenBy> {
  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByGoalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCalories', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByGoalCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCalories', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension DailyLogQueryWhereDistinct
    on QueryBuilder<DailyLog, DailyLog, QDistinct> {
  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByGoalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalCalories');
    });
  }
}

extension DailyLogQueryProperty
    on QueryBuilder<DailyLog, DailyLog, QQueryProperty> {
  QueryBuilder<DailyLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyLog, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyLog, double, QQueryOperations> goalCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalCalories');
    });
  }
}
