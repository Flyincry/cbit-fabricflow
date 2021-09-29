from datetime import timedelta
from textwrap import dedent

# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG

# Operators; we need this to operate!
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

# By using these operators, we can make decision
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator

# These args will get passed on to each operator
# You can override them on a per-task basis during operator initialization
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 1, 1),
    # 'wait_for_downstream': False,
    # 'dag': dag,
    # 'sla': timedelta(hours=2),
    # 'execution_timeout': timedelta(seconds=300),
    # 'on_failure_callback': some_function,
    # 'on_success_callback': some_other_function,
    # 'on_retry_callback': another_function,
    # 'sla_miss_callback': yet_another_function,
    # 'trigger_rule': 'all_success'
}


# input parameters
pn = '0011'
jwl = 'ChowTaiFook'
dt = '20210828' # apply date time
rdt = '20211001' # receive date time
amt = '10000'
bank = 'ICBC'
evall = 'CBIT'
edt = '20211024' # evaluate date time
acdt = '20211111' # accept date time
sup = 'POBC' # supervisor
eddt = '20251225' # end date
pdt = '20251212' # paidback date time
re = 'Zhanbo' # repurchaser
redt = '20211025' # ready date time
repurdt = '20251231' # repurchase date time


# 具体的判断逻辑
def decision_1():
    if int(amt) < 0:
        return "option1"
    return "option2"
def decision_2():
    if int(amt) < 0:
        return "option3"
    return "option4"
def decision_3():
    if int(amt) < 0:
        return "option5"
    return "option6"
def decision_4():
    if int(amt) < 0:
        return "option7"
    return "option8"
def decision_5():
    if int(amt) < 0:
        return "option9"
    return "option10"

# https://stackoverflow.com/questions/61322414/airflow-branchpythonoperator 修改参考链接
with DAG(
    'can_run_dag',
    default_args=default_args,
    description='A test DAG for CBIT',
    schedule_interval=timedelta(days=1),
    start_date=days_ago(2),
    tags=['example'],
) as dag:

    # t1, t2 and t3 are examples of tasks created by instantiating operators


    t1 = BashOperator(
        task_id='Apply',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Apply/Apply',
    )

    t2 = BashOperator(
        task_id='Receive',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Receive/Receive',
        retries=3,
    )

    t3 = BashOperator(
        task_id='Evaluate',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Evaluate/Evaluate',
        retries=3,
    )

    t4 = BashOperator(
        task_id='ReadyRepo',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/ReadyRepo/ReadyRepo',
        retries=3,
    )

    t5 = BashOperator(
        task_id='Accept',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Accept/Accept',
        retries=3,
    )

    t6 = BashOperator(
        task_id='Supervise',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Supervise/Supervise',
        retries=3,
    )

    t7_a = BashOperator(
        task_id='Payback',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Payback/Payback',
        retries=3,
    )

    t7_b = BashOperator(
        task_id='Default',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Default/Default',
        retries=3,
    )

    t8 = BashOperator(
        task_id='Repurchase',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Repurchase/Repurchase',
        retries=3,
    )
    t9 = BashOperator(
        task_id='Reject',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Reject/Reject',
        retries=3,
    )
    t10 = BashOperator(
        task_id='Reject_2',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Reject/Reject',
        retries=3,
    )
    t11 = BashOperator(
        task_id='Reject_3',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Reject/Reject',
        retries=3,
    )
    t12 = BashOperator(
        task_id='Reject_4',
        depends_on_past=False,
        bash_command='/root/go/src/fabric-go-sdk/Action/Reject/Reject',
        retries=3,
    )



    b1 = BranchPythonOperator(
    task_id='branching1',
    python_callable=decision_1,
    trigger_rule='none_failed',
    dag=dag,)
    b2 = BranchPythonOperator(
    task_id='branching2',
    python_callable=decision_2,
    trigger_rule='none_failed',
    dag=dag,)
    b3 = BranchPythonOperator(
    task_id='branching3',
    python_callable=decision_3,
    trigger_rule='none_failed',
    dag=dag,)
    b4 = BranchPythonOperator(
    task_id='branching4',
    python_callable=decision_4,
    trigger_rule='none_failed',
    dag=dag,)
    b5 = BranchPythonOperator(
    task_id='branching5',
    python_callable=decision_5,
    trigger_rule='none_failed',
    dag=dag,)
    
    o1 = DummyOperator(task_id='option1')
    o2 = DummyOperator(task_id='option2')
    o3 = DummyOperator(task_id='option3')
    o4 = DummyOperator(task_id='option4')
    o5 = DummyOperator(task_id='option5')
    o6 = DummyOperator(task_id='option6')
    o7 = DummyOperator(task_id='option7')
    o8 = DummyOperator(task_id='option8')
    o9 = DummyOperator(task_id='option9')
    o10 = DummyOperator(task_id='option10')

    t1 >> b1 >> [o1, o2]  
    o1 >> t9 # Apply --> Reject
    o2 >> t2 >> b2 >> [o3, o4] # Apply --> Receive
    o3 >> t10 # Receive --> Reject
    o4 >> [t3, t4] # Receive --> [Evaluate & ReadyRepo]
    t3 >> b3 >> [o5, o6] # Evaluate --> branching
    t4 >> b4 >> [o7, o8] # ReadyRepo --> branching
    o5 >> t11 # Evaluate --> Reject
    o7 >> t12 # ReadyRepo --> Reject
    [o6, o8] >> t5  # [Evaluate & ReadyRepo] --> Accept
    t5 >> t6 >> b5 >> [o9, o10] # Accept --> Supervise
    o9 >> t7_a # Supervise --> Payback
    o10 >> t7_b >> t8 # Default --> Repurchase