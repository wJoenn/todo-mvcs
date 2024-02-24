type User = {
  id: number
  email: string
}

export const useSessionStore = defineStore("SessionStore", () => {
  const user = ref<User>()
  const bearerToken = ref<string>()

  const authorizationHeader = computed(() => ({ Authorization: bearerToken.value }))
  const isLoggedIn = computed(() => !!bearerToken.value)

  const signIn = (formData: FormData) => _postRequest("/users/sign_in", formData)

  const signInWithToken = async () => {
    bearerToken.value = localStorage.bearerToken

    if (bearerToken.value) {
      try {
        const response = await axios.get<User>(`${import.meta.env.VITE_API_URL}/current_user`, {
          headers: authorizationHeader.value
        })

        user.value = response.data
      } catch {
        _resetState()
      }
    }
  }

  const signOut = async () => {
    axios.delete(`${import.meta.env.VITE_API_URL}/users/sign_out`, {
      headers: authorizationHeader.value
    })

    _resetState()
  }

  const signUp = (formData: FormData) => _postRequest("/users", formData)

  const _postRequest = async (endPoint: string, formData: FormData) => {
    try {
      const params = { user: Object.fromEntries(formData) }
      const response = await axios.post<User>(`${import.meta.env.VITE_API_URL}${endPoint}`, params, {
        headers: { "Content-Type": "application/json" }
      })

      user.value = response.data
      bearerToken.value = response.headers.authorization
      localStorage.bearerToken = bearerToken.value
    } catch (error: any) {
      return error.response.data.errors
    }
  }

  const _resetState = () => {
    user.value = undefined
    bearerToken.value = undefined
    localStorage.removeItem("bearerToken")
  }

  return { user, isLoggedIn, signIn, signInWithToken, signOut, signUp }
})
