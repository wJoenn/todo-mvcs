<template>
  <div class="tasks-table">
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Title</th>
          <th>Status</th>
          <th />
        </tr>
      </thead>

      <TransitionGroup tag="tbody" :name="transitionName">
        <tr v-for="(task, index) in tasks" :key="task.id">
          <td class="id">{{ task.id }}</td>
          <td class="title">{{ task.title }}</td>
          <td class="status">
            <p>
              <Icon
                :icon="task.completed ? 'icon-park-outline:check-one' : 'fa:circle-thin'"
                @click="$emit('complete', { id: task.id, index })" />

              <span>{{ task.completed ? 'Done' : 'Todo' }}</span>
            </p>
          </td>
          <td class="delete"><Icon icon="fa6-solid:delete-left" @click="$emit('delete', task.id)" /></td>
        </tr>
      </TransitionGroup>
    </table>
  </div>
</template>

<script setup lang="ts">
  import type { Task } from "~/types"
  import { Icon } from "@iconify/vue"

  defineEmits<{
    (event: "complete", payload: { id: number, index: number }): void
    (event: "delete", payload: number): void
  }>()

  const props = defineProps<{
    tasks: Task[]
  }>()

  const tableTransition = ref("0")
  const transitionName = ref("disabled")

  const tableHeight = computed(() => `${(props.tasks.length + 1) * 46}px`)

  watch(() => props.tasks, (_, oldValue) => {
    if (oldValue.length === 0) {
      setTimeout(() => {
        tableTransition.value = "0.3s"
        transitionName.value = "tasks"
      }, 100)
    }
  })

  onMounted(() => {

  })
</script>

<style scoped lang="scss">
  .tasks-table {
    height: v-bind(tableHeight);
    transition: height v-bind(tableTransition) ease;
    border: $border-dark;
    border-radius: 5px;
    overflow: hidden;

    table {
      border-spacing: 0;

      tr {
        height: 46px;

        &:last-of-type {
          td {
            border: none;
          }
        }

        svg {
          cursor: pointer;
          height: 15px;
          width: 15px;
          transition: color 0.3s ease;

          &:hover {
            color: $nuxt-green-light;
          }
        }

        td, th {
          border-bottom: $border-dark;
          padding: $size-sm $size;
        }

        th {
          color: $text-secondary;
          font-size: $size-md;
          font-weight: 500;
          text-align: left;
        }

        .delete, .id {
          min-width: 65px;
        }

        .status {
          min-width: 200px;

          p {
            align-items: center;
            display: flex;
            gap: 10px;
          }
        }

        .title {
          overflow-wrap: break-word;
          width: 1000px;
        }
      }
    }
  }

  .tasks-leave-to,
  .tasks-enter-from {
    opacity: 0;
    transform: translateX(30px);
  }

  .tasks-leave-active {
    position: absolute;
    max-width: calc(Min(95%, 1200px) - 70px);
  }

  .tasks-move,
  .tasks-enter-active,
  .tasks-leave-active {
    transition: all 0.3s ease;
  }
</style>