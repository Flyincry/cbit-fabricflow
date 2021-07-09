#### Testing for DAGs

from airflow.models import DagBag
import unittest

class TestHelloWorldDAG(unittest.TestCase):
   @classmethod
   def setUpClass(cls):
       cls.dagbag = DagBag()

   def test_dag_loaded(self):
       dag = self.dagbag.get_dag(dag_id='hello_world')
       assert self.dagbag.import_errors == {}
       assert dag is not None
       assert len(dag.tasks) == 1
        
### Unit test a DAG structure
import unittest
class testClass(unittest.TestCase):
    def assertDagDictEqual(self,source,dag):
        assert dag.task_dict.keys() == source.keys()
        for task_id, downstream_list in source.items():
            assert dag.has_task(task_id)
            task = dag.get_task(task_id)
            assert task.downstream_task_ids == set(downstream_list)
    def test_dag(self):
        self.assertDagDictEqual({
          "DummyInstruction_0": ["DummyInstruction_1"],
          "DummyInstruction_1": ["DummyInstruction_2"],
          "DummyInstruction_2": ["DummyInstruction_3"],
          "DummyInstruction_3": []
        },dag)
        
### Unit test for custom operator
import unittest
from airflow.utils.state import State

DEFAULT_DATE = '2019-10-03'
TEST_DAG_ID = 'test_my_custom_operator'

class MyCustomOperatorTest(unittest.TestCase):
   def setUp(self):
       self.dag = DAG(TEST_DAG_ID, schedule_interval='@daily', default_args={'start_date' : DEFAULT_DATE})
       self.op = MyCustomOperator(
           dag=self.dag,
           task_id='test',
           prefix='s3://bucket/some/prefix',
       )
       self.ti = TaskInstance(task=self.op, execution_date=DEFAULT_DATE)

   def test_execute_no_trigger(self):
       self.ti.run(ignore_ti_state=True)
       assert self.ti.state == State.SUCCESS
       # Assert something related to tasks results
### SelfCheck

task = PushToS3(...)
check = S3KeySensor(
   task_id='check_parquet_exists',
   bucket_key="s3://bucket/key/foo.parquet",
   poke_interval=0,
   timeout=0
)
task >> check


### Faking Variables
with mock.patch.dict('os.environ', AIRFLOW_VAR_KEY="env-value"):
    assert "env-value" == Variable.get("key")
conn = Connection(
    conn_type="gcpssh",
    login="cat",
    host="conn-host",
)
conn_uri = conn.get_uri()
with mock.patch.dict("os.environ", AIRFLOW_CONN_MY_CONN=conn_uri):
  assert "cat" == Connection.get("my_conn").login
