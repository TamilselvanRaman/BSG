import { redirect } from "next/navigation";

export default function WorkspaceRedirect() {
  redirect("/super-admin/dashboard");
}
